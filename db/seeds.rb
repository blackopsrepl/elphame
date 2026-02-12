# Idempotent seeding — NEVER destroy existing data
puts "Checking realms..."

realms_data = [
  {
    name: "The Writ",
    slug: "the-writ",
    description: "Where decree becomes deed. Tasks, action items, tracking. The scroll of commands that must be answered.",
    icon: "📜",
    color: "#dc2626",
    position: 0
  },
  {
    name: "The Threshold",
    slug: "the-threshold",
    description: "Where mortals first cross into Elphame. Questions, greetings, navigation, introductions.",
    icon: "🚪",
    color: "#7e22ce",
    position: 1
  },
  {
    name: "Forbidden Knowledge",
    slug: "forbidden-knowledge",
    description: "Technical discussion. Technology, code, systems, the dangerous truths hidden in plain sight.",
    icon: "🔮",
    color: "#059669",
    position: 2
  },
  {
    name: "The Deepening",
    slug: "the-deepening",
    description: "Philosophy, consciousness, dreams, existential paradox. The questions that spiral inward.",
    icon: "🌀",
    color: "#4f46e5",
    position: 3
  },
  {
    name: "Random",
    slug: "random",
    description: "Chaos. Jokes. Shitposts. Anything. Everything. The unclassifiable.",
    icon: "🎲",
    color: "#d97706",
    position: 4
  }
]

realms_data.each do |realm_data|
  slug = realm_data[:slug] || realm_data[:name].parameterize
  existing = Realm.find_by(slug: slug)
  if existing
    puts "  ✓ #{realm_data[:name]} (exists)"
  else
    Realm.create!(realm_data)
    puts "  ✓ #{realm_data[:name]} (created)"
  end
end

puts "\n#{Realm.count} realms exist in the-place-that-is-not."

# Root admin user (idempotent)
puts "\nChecking root admin user..."

root_username = ENV["ELPHAME_ROOT_USER"] || "root"
root_password = ENV["ELPHAME_ROOT_PASSWORD"] || "changeme"
root_email = ENV["ELPHAME_ROOT_EMAIL"] || "root@elphame.local"

if User.exists?(username: root_username)
  puts "  ✓ Root user '#{root_username}' exists"
else
  User.create!(
    username: root_username,
    email: root_email,
    password: root_password,
    password_confirmation: root_password,
    admin: true
  )
  puts "  ✓ Root user '#{root_username}' created"
  puts "    Email: #{root_email}"
  puts "    Password: #{root_password}"
  puts ""
  puts "    ⚠️  CHANGE THIS PASSWORD IMMEDIATELY!"
  puts "    Visit: http://localhost:3000/users/edit"
  puts ""
end

# Labels (idempotent via find_or_create_by)
if defined?(Label)
  puts "\nChecking labels..."

  LABELS_CONFIG = {
    priority: [
      { name: "urgent", emoji: "🔴", sort_weight: 100 },
      { name: "important", emoji: "🟡", sort_weight: 50 },
      { name: "enhancement", emoji: "🔵", sort_weight: 0 },
      { name: "reference", emoji: "⚪", sort_weight: 0 }
    ],
    status: [
      { name: "blocked", emoji: "🚧", sort_weight: 30 },
      { name: "needs-input", emoji: "💬", sort_weight: 40 },
      { name: "resolved", emoji: "✅", sort_weight: -50 },
      { name: "pinned", emoji: "📌", sort_weight: 1000 }
    ],
    type: [
      { name: "general", emoji: "💬", sort_weight: 0, user_selectable: true },
      { name: "research", emoji: "🔬", sort_weight: 0, user_selectable: true },
      { name: "decision", emoji: "⚖️", sort_weight: 0, user_selectable: true },
      { name: "question", emoji: "❓", sort_weight: 0, user_selectable: true },
      { name: "archive", emoji: "📦", sort_weight: 0, user_selectable: true },
      { name: "meta", emoji: "🔧", sort_weight: 0, user_selectable: true },
      { name: "technical", emoji: "⚙️", sort_weight: 0, user_selectable: true },
      { name: "philosophical", emoji: "🤔", sort_weight: 0, user_selectable: true },
      { name: "announcement", emoji: "📢", sort_weight: 0, user_selectable: true },
      { name: "feedback", emoji: "📣", sort_weight: 0, user_selectable: true },
      { name: "showcase", emoji: "🎨", sort_weight: 0, user_selectable: true },
      { name: "help", emoji: "🆘", sort_weight: 0, user_selectable: true },
      { name: "discussion", emoji: "💭", sort_weight: 0, user_selectable: true },
      { name: "project", emoji: "📋", sort_weight: 0, user_selectable: true },
      { name: "idea", emoji: "💡", sort_weight: 0, user_selectable: true },
      { name: "bug", emoji: "🐛", sort_weight: 0, user_selectable: true },
      { name: "docs", emoji: "📚", sort_weight: 0, user_selectable: true }
    ]
  }

  LABELS_CONFIG.each do |category, labels|
    labels.each_with_index do |config, idx|
      Label.find_or_create_by!(name: config[:name]) do |label|
        label.category = category.to_s
        label.emoji = config[:emoji]
        label.sort_weight = config[:sort_weight]
        label.position = idx
        label.user_selectable = config[:user_selectable] || false
      end
      puts "  ✓ #{config[:emoji]} #{config[:name]}"
    end
  end

  puts "\n#{Label.count} labels mark the paths through Elphame."
end
