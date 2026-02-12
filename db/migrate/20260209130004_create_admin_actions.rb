class CreateAdminActions < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_actions do |t|
      t.references :admin_user, null: false, foreign_key: { to_table: :users }
      t.string :action_type, null: false
      t.string :target_type
      t.integer :target_id
      t.text :details
      t.timestamps
    end

    add_index :admin_actions, :action_type
    add_index :admin_actions, [ :target_type, :target_id ]
    add_index :admin_actions, :created_at
  end
end
