class RecalculateReplyCounts < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE discussions
      SET reply_count_cache = (
        SELECT COUNT(*) FROM posts WHERE posts.discussion_id = discussions.id
      )
    SQL
  end

  def down
    # No-op — cache can always be recalculated
  end
end
