class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :discussion, null: false, foreign_key: true
      t.text :content
      t.string :image

      t.timestamps
    end
  end
end
