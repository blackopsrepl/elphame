class AddIndexesAndCounterCacheToRealms < ActiveRecord::Migration[8.1]
  def change
    add_index :realms, :name, unique: true
    add_index :realms, :slug, unique: true
    add_column :realms, :discussions_count, :integer, default: 0, null: false
  end
end
