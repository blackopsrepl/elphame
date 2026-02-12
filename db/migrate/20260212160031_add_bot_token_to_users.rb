class AddBotTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :bot_token, :string
    add_index :users, :bot_token, unique: true
    change_column_null :users, :encrypted_password, true
    change_column_null :users, :email, true
  end
end
