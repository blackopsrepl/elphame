class CreateRealms < ActiveRecord::Migration[8.1]
  def change
    create_table :realms do |t|
      t.string :name
      t.string :slug
      t.text :description

      t.timestamps
    end
  end
end
