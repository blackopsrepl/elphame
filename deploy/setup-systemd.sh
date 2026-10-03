#!/bin/bash

# Setup script for Elphame systemd service
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="elphame"
APP_PATH="/srv/lab/dev/elphame"
SERVICE_FILE="elphame.service"
ENV_SERVICE_FILE="elphame-with-env.service"
SYSTEMD_PATH="/etc/systemd/system"
DEPLOY_USER="deploy"

echo -e "${GREEN}Elphame Systemd Service Setup${NC}"
echo "================================"

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}This script must be run as root${NC}"
        exit 1
    fi
}

# Function to create deploy user if it doesn't exist
create_deploy_user() {
    if ! id "$DEPLOY_USER" &>/dev/null; then
        echo -e "${YELLOW}Creating deploy user...${NC}"
        useradd -m -s /bin/bash $DEPLOY_USER
        echo -e "${GREEN}Deploy user created${NC}"
    else
        echo -e "${GREEN}Deploy user already exists${NC}"
    fi
}

# Function to setup Ruby environment
setup_ruby() {
    echo -e "${YELLOW}Setting up Ruby environment...${NC}"
    
    # Check if rbenv is installed for deploy user
    if ! su - $DEPLOY_USER -c "command -v rbenv" &>/dev/null; then
        echo -e "${YELLOW}Installing rbenv for deploy user...${NC}"
        su - $DEPLOY_USER -c "git clone https://github.com/rbenv/rbenv.git ~/.rbenv"
        su - $DEPLOY_USER -c "git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build"
        su - $DEPLOY_USER -c "echo 'export PATH=\"\$HOME/.rbenv/bin:\$PATH\"' >> ~/.bashrc"
        su - $DEPLOY_USER -c "echo 'eval \"\$(rbenv init -)\"' >> ~/.bashrc"
    fi
    
    # Install Ruby version
    RUBY_VERSION=$(cat $APP_PATH/.ruby-version | tr -d '\n')
    echo -e "${YELLOW}Installing Ruby $RUBY_VERSION...${NC}"
    su - $DEPLOY_USER -c "rbenv install -s $RUBY_VERSION"
    su - $DEPLOY_USER -c "rbenv global $RUBY_VERSION"
    
    # Install bundler
    su - $DEPLOY_USER -c "gem install bundler"
    
    echo -e "${GREEN}Ruby environment setup complete${NC}"
}

# Function to setup application
setup_application() {
    echo -e "${YELLOW}Setting up application...${NC}"
    
    # Change ownership
    chown -R $DEPLOY_USER:$DEPLOY_USER $APP_PATH
    
    # Install dependencies
    echo -e "${YELLOW}Installing gem dependencies...${NC}"
    su - $DEPLOY_USER -c "cd $APP_PATH && bundle install"
    
    # Setup database (if in production)
    if [[ -f "$APP_PATH/.env.production" ]]; then
        echo -e "${YELLOW}Running database setup...${NC}"
        su - $DEPLOY_USER -c "cd $APP_PATH && RAILS_ENV=production bundle exec rails db:create db:migrate"
        
        echo -e "${YELLOW}Precompiling assets...${NC}"
        su - $DEPLOY_USER -c "cd $APP_PATH && RAILS_ENV=production bundle exec rails assets:precompile"
    fi
    
    echo -e "${GREEN}Application setup complete${NC}"
}

# Function to install systemd service
install_service() {
    echo -e "${YELLOW}Installing systemd service...${NC}"
    
    # Ask which service file to use
    echo "Which service file would you like to install?"
    echo "1) Basic service (elphame.service)"
    echo "2) Service with environment file (elphame-with-env.service)"
    read -p "Enter choice [1-2]: " choice
    
    case $choice in
        1)
            SERVICE_TO_INSTALL=$SERVICE_FILE
            ;;
        2)
            SERVICE_TO_INSTALL=$ENV_SERVICE_FILE
            # Check for environment file
            if [[ ! -f "$APP_PATH/.env.production" ]]; then
                echo -e "${YELLOW}Creating .env.production from example...${NC}"
                cp $APP_PATH/elphame.env.example $APP_PATH/.env.production
                echo -e "${RED}Please edit $APP_PATH/.env.production with your configuration${NC}"
                echo "Press any key to continue after editing..."
                read -n 1
            fi
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
    
    # Copy service file
    cp $APP_PATH/$SERVICE_TO_INSTALL $SYSTEMD_PATH/$APP_NAME.service
    
    # Reload systemd
    systemctl daemon-reload
    
    echo -e "${GREEN}Service installed successfully${NC}"
}

# Function to manage service
manage_service() {
    echo -e "${YELLOW}Service Management${NC}"
    echo "1) Start service"
    echo "2) Stop service"
    echo "3) Restart service"
    echo "4) Enable service (start on boot)"
    echo "5) Disable service"
    echo "6) Show service status"
    echo "7) Show service logs"
    echo "8) Skip"
    read -p "Enter choice [1-8]: " choice
    
    case $choice in
        1)
            systemctl start $APP_NAME
            echo -e "${GREEN}Service started${NC}"
            ;;
        2)
            systemctl stop $APP_NAME
            echo -e "${GREEN}Service stopped${NC}"
            ;;
        3)
            systemctl restart $APP_NAME
            echo -e "${GREEN}Service restarted${NC}"
            ;;
        4)
            systemctl enable $APP_NAME
            echo -e "${GREEN}Service enabled${NC}"
            ;;
        5)
            systemctl disable $APP_NAME
            echo -e "${GREEN}Service disabled${NC}"
            ;;
        6)
            systemctl status $APP_NAME
            ;;
        7)
            journalctl -u $APP_NAME -f
            ;;
        8)
            echo "Skipping service management"
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
}

# Main execution
main() {
    check_root
    
    echo "What would you like to do?"
    echo "1) Complete setup (user, Ruby, app, service)"
    echo "2) Install/update service only"
    echo "3) Manage existing service"
    read -p "Enter choice [1-3]: " main_choice
    
    case $main_choice in
        1)
            create_deploy_user
            setup_ruby
            setup_application
            install_service
            manage_service
            ;;
        2)
            install_service
            manage_service
            ;;
        3)
            manage_service
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}Setup complete!${NC}"
    echo ""
    echo "Useful commands:"
    echo "  systemctl start $APP_NAME      # Start the service"
    echo "  systemctl stop $APP_NAME       # Stop the service"
    echo "  systemctl restart $APP_NAME    # Restart the service"
    echo "  systemctl status $APP_NAME     # Check service status"
    echo "  journalctl -u $APP_NAME -f     # View service logs"
    echo "  systemctl enable $APP_NAME     # Enable service on boot"
}

# Run main function
main