class DropFeaturedFromDiscussions < ActiveRecord::Migration[8.1]
  def change
    remove_index :discussions, :featured
    remove_column :discussions, :featured, :boolean, default: false
  end
end
