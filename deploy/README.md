# Elphame deployment templates

Production/staging deployment assets. These are **templates**, not runnable
configuration: replace every path and placeholder before installing anything.
For the full walkthrough see [docs/deployment.md](../docs/deployment.md).

| File | Purpose |
| --- | --- |
| `elphame.service` | systemd unit for a simple single-user install (no env file, runs in `development`). |
| `elphame-with-env.service` | hardened systemd unit that reads `EnvironmentFile=.env.production` and runs Puma in production. |
| `elphame.env.example` | template for that environment file. |
| `setup-systemd.sh` | interactive helper that installs one of the units and can manage the service. |

## Placeholders to replace

`elphame-with-env.service` and `setup-systemd.sh` assume a dedicated deploy
account and a specific checkout location. Adjust to match your host:

- `User=` / `Group=` — the account that owns the checkout.
- `WorkingDirectory=` / `ReadWritePaths=` — the absolute path to the checkout.
- `EnvironmentFile=` — the path to your `.env.production`.
- `PATH=` — the shim directory of your Ruby manager (`rbenv`, `asdf`, `mise`).
- `ExecStart=` — the `bundle exec puma -C config/puma.rb` invocation for that Ruby.

`setup-systemd.sh` creates a `deploy` user and installs `rbenv` if absent. Read
it before running it; it needs root.

## Minimal install

```bash
cp deploy/elphame.env.example .env.production
$EDITOR .env.production                     # SECRET_KEY_BASE, RAILS_HOST, ...
sudo cp deploy/elphame-with-env.service /etc/systemd/system/elphame.service
sudo systemctl daemon-reload
sudo systemctl enable --now elphame
journalctl -u elphame -f
```
