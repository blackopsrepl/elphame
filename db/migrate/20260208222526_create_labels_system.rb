class CreateLabelsSystem < ActiveRecord::Migration[8.1]
  def change
    # Label definitions table
    create_table :labels do |t|
      t.string :name, null: false           # e.g., "urgent", "bug", "resolved"
      t.string :category, null: false       # "priority", "status", "category"
      t.string :emoji                       # 🔴, 🐛, ✅
      t.integer :sort_weight, default: 0   # Used in scoring algorithm
      t.integer :position, default: 0      # Display order
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :labels, [ :category, :position ]
    add_index :labels, :active

    # Thread labels (join table)
    create_table :thread_labels do |t|
      t.references :discussion, null: false, foreign_key: true
      t.references :label, null: false, foreign_key: true
      t.references :applied_by_user, foreign_key: { to_table: :users }
      t.datetime :applied_at, null: false

      t.timestamps
    end

    add_index :thread_labels, [ :discussion_id, :label_id ], unique: true
    add_index :thread_labels, :applied_at
  end
end
