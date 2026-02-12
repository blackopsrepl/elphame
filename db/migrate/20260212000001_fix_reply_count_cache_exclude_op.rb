class FixReplyCountCacheExcludeOp < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE discussions
      SET reply_count_cache = CASE
        WHEN (SELECT COUNT(*) FROM posts WHERE posts.discussion_id = discussions.id) > 1
        THEN (SELECT COUNT(*) FROM posts WHERE posts.discussion_id = discussions.id) - 1
        ELSE 0
      END
    SQL
  end

  def down
    execute <<~SQL
      UPDATE discussions
      SET reply_count_cache = (
        SELECT COUNT(*) FROM posts WHERE posts.discussion_id = discussions.id
      )
    SQL
  end
end
