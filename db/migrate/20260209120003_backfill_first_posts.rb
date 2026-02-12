class BackfillFirstPosts < ActiveRecord::Migration[8.1]
  def up
    # Create first posts for discussions that don't have any posts yet
    Discussion.find_each do |discussion|
      next if discussion.posts.any?
      next if discussion.content.blank?

      # Skip if content is too long (would violate Post validation)
      if discussion.content.length > 2000
        puts "Skipping Discussion ##{discussion.id}: content too long (#{discussion.content.length} chars)"
        next
      end

      discussion.posts.create!(
        content: discussion.content,
        user: discussion.user,
        author_name: discussion.author_name,
        soft_username: discussion.soft_username,
        created_at: discussion.created_at,
        updated_at: discussion.updated_at
      )

      puts "Created first post for Discussion ##{discussion.id}"
    end
  end

  def down
    # Cannot automatically reverse this
    # Posts would need to be manually identified and removed
  end
end
