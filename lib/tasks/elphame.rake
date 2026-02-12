namespace :elphame do
  desc "Initialize activity tracking for existing discussions"
  task initialize_activity: :environment do
    puts "Initializing activity tracking for existing discussions..."

    Discussion.find_each do |discussion|
      # Set last_activity_at if not set
      if discussion.last_activity_at.nil?
        last_post = discussion.posts.order(:created_at).last
        discussion.update_column(:last_activity_at, last_post&.created_at || discussion.created_at)
      end

      # Update reply count cache (exclude OP)
      discussion.update_column(:reply_count_cache, [ discussion.posts.count - 1, 0 ].max)

      print "."
    end

    puts "\n Done. Initialized #{Discussion.count} discussions"
  end
end
