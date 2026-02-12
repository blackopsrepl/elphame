class AddUserAndSoftUsernameToDiscussions < ActiveRecord::Migration[8.1]
  def change
    add_reference :discussions, :user, foreign_key: true, null: true
    add_column :discussions, :soft_username, :string
    add_index :discussions, :soft_username
  end
end
