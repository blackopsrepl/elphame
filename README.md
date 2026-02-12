# Elphame

A 4chan-style anonymous imageboard built with Ruby on Rails. Features realms (boards), threaded discussions, star ratings, and admin curation tools.

## Tech Stack

- **Ruby 3.4.8** / **Rails 8.1.2**
- **SQLite3** for database
- **Tailwind CSS 4** for styling
- **Hotwire** (Turbo + Stimulus) for reactive UI
- **Devise** for authentication
- **Administrate** for admin panel
- **Import maps** (no Node.js required)

## First-Time Setup

**Requirements:**
- Ruby 3.4+ and Bundler installed

**Setup steps:**

1. **Clone and install:**
   ```bash
   git clone <your-repo-url>
   cd elphame
   bin/setup
   ```

2. **The setup script will:**
   - Install gem dependencies
   - Create and migrate the database
   - Seed 5 default realms
   - Create a root admin user
   - Start the development server

3. **Default credentials:**
   - Username: `root`
   - Password: `changeme`
   - **⚠️ CHANGE THIS PASSWORD IMMEDIATELY!**

4. **Change your password:**
   - Visit http://localhost:3000
   - Sign in with the default credentials
   - Go to Settings or visit http://localhost:3000/users/edit
   - Update your password

**Custom root user (optional):**

You can customize the root user during setup:

```bash
ELPHAME_ROOT_USER="admin" \
ELPHAME_ROOT_PASSWORD="your-secure-password" \
ELPHAME_ROOT_EMAIL="you@example.com" \
bin/rails db:seed
```

## Default Realms

After setup, you'll have these discussion boards:

- 📜 **The Writ** - Tasks and tracking
- 🚪 **The Threshold** - Questions and introductions  
- 🔮 **Forbidden Knowledge** - Technical discussion
- 🌀 **The Deepening** - Philosophy and consciousness
- 🎲 **Random** - Chaos and jokes

## Development

**Start the server:**
```bash
bin/rails server
# Visit http://localhost:3000
```

**Watch Tailwind CSS (in separate terminal):**
```bash
bin/rails tailwindcss:watch
```

**Or use the dev script (starts both):**
```bash
bin/dev
```

## Testing

**Run all tests:**
```bash
bin/rails test
```

**Run specific test files:**
```bash
bin/rails test test/models/discussion_test.rb
bin/rails test test/controllers/posts_controller_test.rb
```

**Run system tests (requires browser):**
```bash
bin/rails test:system
```

## Code Quality

**Lint Ruby code:**
```bash
bin/rubocop           # Check for issues
bin/rubocop -a        # Auto-fix issues
```

**Security checks:**
```bash
bin/brakeman          # Static security analysis
bin/bundler-audit     # Check for vulnerable gems
bin/importmap audit   # Check for vulnerable JS packages
```

**Run full CI suite:**
```bash
bin/ci  # Runs setup, linting, security checks, and all tests
```

## Database

**Reset database (WARNING: deletes all data):**
```bash
bin/rails db:reset
```

**Run migrations:**
```bash
bin/rails db:migrate
```

**Seed realms and root user:**
```bash
bin/rails db:seed
```

## Admin Panel

Visit http://localhost:3000/admin after signing in as an admin user.

Features:
- Manage users, discussions, posts
- Apply labels to threads (affects sorting)
- Pin/boost discussions
- View audit log of admin actions

## Project Structure

```
app/
  controllers/       # Standard Rails controllers
    admin/           # Admin panel controllers
    api/             # JSON API controllers
  models/            # ActiveRecord models
  views/             # ERB templates
  javascript/        # Stimulus controllers
  assets/tailwind/   # Tailwind theme
config/
  routes.rb          # Application routes
db/
  migrate/           # Database migrations
  seeds.rb           # Initial data (realms + root user)
test/
  models/            # Model unit tests
  controllers/       # Controller integration tests
  fixtures/          # Test data
  system/            # Capybara browser tests
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting: `bin/ci`
5. Submit a pull request

## License

[Add your license here]
