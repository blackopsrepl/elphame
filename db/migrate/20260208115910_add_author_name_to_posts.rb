class AddAuthorNameToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :author_name, :string
  end
end
