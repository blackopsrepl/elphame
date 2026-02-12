class AddQuotedPostToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :quoted_post, null: true, foreign_key: { to_table: :posts }
  end
end
