class AddManualCurationToDiscussions < ActiveRecord::Migration[8.1]
  def change
    add_column :discussions, :pinned, :boolean, default: false, null: false
    add_column :discussions, :pinned_at, :datetime
    add_column :discussions, :pinned_by_user_id, :integer

    add_column :discussions, :featured, :boolean, default: false
    add_column :discussions, :manual_boost_score, :integer, default: 0

    # Activity tracking for smart sort
    add_column :discussions, :last_activity_at, :datetime
    add_column :discussions, :reply_count_cache, :integer, default: 0
    add_column :discussions, :star_count_cache, :integer, default: 0

    add_index :discussions, :pinned
    add_index :discussions, :featured
    add_index :discussions, :last_activity_at

    add_foreign_key :discussions, :users, column: :pinned_by_user_id
  end
end
