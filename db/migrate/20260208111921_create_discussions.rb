class CreateDiscussions < ActiveRecord::Migration[8.1]
  def change
    create_table :discussions do |t|
      t.references :realm, null: false, foreign_key: true
      t.string :subject
      t.text :content
      t.string :image

      t.timestamps
    end
  end
end
