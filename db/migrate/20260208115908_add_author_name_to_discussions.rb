class AddAuthorNameToDiscussions < ActiveRecord::Migration[8.1]
  def change
    add_column :discussions, :author_name, :string
  end
end
