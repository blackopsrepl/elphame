class AddUserAndSoftUsernameToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :user, foreign_key: true, null: true
    add_column :posts, :soft_username, :string
    add_index :posts, :soft_username
  end
end
