class AddTagToDiscussions < ActiveRecord::Migration[8.1]
  def change
    add_column :discussions, :tag, :string, default: "general"
  end
end
