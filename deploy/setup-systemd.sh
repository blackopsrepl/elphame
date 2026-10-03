#!/usr/bin/env bash
#
# Install and manage the Elphame systemd service. Must run as root.
#
# Reads the unit files from the deploy/ directory next to this script, so the
# script works from a checkout in any location. See deploy/README.md and
# docs/deployment.md.
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_NAME="elphame"
# Resolve the checkout from this script's location rather than hardcoding a host
# path: the units live in deploy/, so the checkout is one level up.
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="$(cd "$DEPLOY_DIR/.." && pwd)"
SERVICE_FILE="$DEPLOY_DIR/elphame.service"
ENV_SERVICE_FILE="$DEPLOY_DIR/elphame-with-env.service"
ENV_EXAMPLE="$DEPLOY_DIR/elphame.env.example"
SYSTEMD_PATH="/etc/systemd/system"

# Adjust these for your host before running.
DEPLOY_USER="${ELPHAME_DEPLOY_USER:-deploy}"
RUBY_MANAGER="${ELPHAME_RUBY_MANAGER:-rbenv}"

echo -e "${GREEN}Elphame systemd service setup${NC}"
echo "======================================="
echo "checkout:   $APP_PATH"
echo "deploy dir: $DEPLOY_DIR"
echo "deploy user: $DEPLOY_USER"
echo

check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root${NC}" >&2
    exit 1
  fi
}

require_units() {
  for f in "$SERVICE_FILE" "$ENV_SERVICE_FILE" "$ENV_EXAMPLE"; do
    if [[ ! -f "$f" ]]; then
      echo -e "${RED}missing unit file: $f${NC}" >&2
      exit 1
    fi
  done
}

create_deploy_user() {
  if id "$DEPLOY_USER" &>/dev/null; then
    echo -e "${GREEN}user $DEPLOY_USER already exists${NC}"
  else
    echo -e "${YELLOW}creating user $DEPLOY_USER...${NC}"
    useradd -m -s /bin/bash "$DEPLOY_USER"
  fi
}

setup_ruby() {
  echo -e "${YELLOW}setting up $RUBY_MANAGER for $DEPLOY_USER...${NC}"
  case "$RUBY_MANAGER" in
    rbenv)
      if ! su - "$DEPLOY_USER" -c "command -v rbenv" &>/dev/null; then
        su - "$DEPLOY_USER" -c "git clone https://github.com/rbenv/rbenv.git ~/.rbenv"
        su - "$DEPLOY_USER" -c "git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build"
        su - "$DEPLOY_USER" -c "echo 'export PATH=\"\$HOME/.rbenv/bin:\$PATH\"' >> ~/.bashrc"
      fi
      ruby_version="$(tr -d '[:space:]' < "$APP_PATH/.ruby-version")"
      echo -e "${YELLOW}installing Ruby ${ruby_version}...${NC}"
      su - "$DEPLOY_USER" -c "rbenv install -s $ruby_version"
      su - "$DEPLOY_USER" -c "rbenv global $ruby_version"
      su - "$DEPLOY_USER" -c "gem install bundler"
      ;;
    *)
      echo -e "${YELLOW}skipping Ruby install for $RUBY_MANAGER (handle it yourself)${NC}"
      ;;
  esac
}

setup_application() {
  echo -e "${YELLOW}installing gem dependencies...${NC}"
  chown -R "$DEPLOY_USER:$DEPLOY_USER" "$APP_PATH"
  su - "$DEPLOY_USER" -c "cd '$APP_PATH' && bundle install"

  if [[ -f "$APP_PATH/.env.production" ]]; then
    echo -e "${YELLOW}preparing the production database...${NC}"
    # SQLite: db:prepare creates and migrates in one step. There is no db:create
    # to call separately, and no external database server to provision.
    su - "$DEPLOY_USER" -c "cd '$APP_PATH' && RAILS_ENV=production bundle exec rails db:prepare"
    su - "$DEPLOY_USER" -c "cd '$APP_PATH' && RAILS_ENV=production bundle exec rails tailwindcss:build"
  else
    echo -e "${YELLOW}no .env.production yet; skipping database and asset build${NC}"
  fi
}

install_service() {
  echo -e "${YELLOW}installing the systemd service...${NC}"
  echo "1) basic unit (development, no env file) — elphame.service"
  echo "2) hardened unit (production, reads .env.production) — elphame-with-env.service"
  read -r -p "choice [1-2]: " choice

  case "$choice" in
    1) source_unit="$SERVICE_FILE" ;;
    2)
      source_unit="$ENV_SERVICE_FILE"
      if [[ ! -f "$APP_PATH/.env.production" ]]; then
        echo -e "${YELLOW}creating .env.production from the template...${NC}"
        cp "$ENV_EXAMPLE" "$APP_PATH/.env.production"
        chown "$DEPLOY_USER:$DEPLOY_USER" "$APP_PATH/.env.production"
        echo -e "${RED}edit $APP_PATH/.env.production now: set SECRET_KEY_BASE and RAILS_HOST${NC}"
        read -r -n 1 -p "press any key when done..."
        echo
      fi
      ;;
    *)
      echo -e "${RED}invalid choice${NC}" >&2
      exit 1
      ;;
  esac

  install -m 0644 "$source_unit" "$SYSTEMD_PATH/$APP_NAME.service"
  systemctl daemon-reload
  echo -e "${GREEN}installed $SYSTEMD_PATH/$APP_NAME.service${NC}"
  echo -e "${YELLOW}before starting: check User=, WorkingDirectory=, EnvironmentFile= and PATH= in that unit${NC}"
}

manage_service() {
  echo -e "${YELLOW}service management${NC}"
  echo "1) start  2) stop  3) restart  4) enable on boot  5) disable  6) status  7) logs  8) skip"
  read -r -p "choice [1-8]: " choice
  case "$choice" in
    1) systemctl start "$APP_NAME" ;;
    2) systemctl stop "$APP_NAME" ;;
    3) systemctl restart "$APP_NAME" ;;
    4) systemctl enable "$APP_NAME" ;;
    5) systemctl disable "$APP_NAME" ;;
    6) systemctl status "$APP_NAME" || true ;;
    7) journalctl -u "$APP_NAME" -f ;;
    8) echo "skipping" ;;
    *) echo -e "${RED}invalid choice${NC}" >&2 ;;
  esac
}

main() {
  check_root
  require_units

  echo "1) complete setup (user, Ruby, app, service)"
  echo "2) install/update the service only"
  echo "3) manage an existing service"
  read -r -p "choice [1-3]: " main_choice

  case "$main_choice" in
    1) create_deploy_user; setup_ruby; setup_application; install_service; manage_service ;;
    2) install_service; manage_service ;;
    3) manage_service ;;
    *) echo -e "${RED}invalid choice${NC}" >&2; exit 1 ;;
  esac

  echo
  echo -e "${GREEN}done${NC}"
  echo "  systemctl start|stop|restart|status $APP_NAME"
  echo "  journalctl -u $APP_NAME -f"
  echo "  bin/health-check.sh                 # from the checkout, as the app user"
}

main "$@"
