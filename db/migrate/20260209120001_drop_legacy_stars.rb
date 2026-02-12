class DropLegacyStars < ActiveRecord::Migration[8.1]
  def up
    drop_table :stars if table_exists?(:stars)

    # Clean up old cache columns that are now replaced
    remove_column :discussions, :star_count_cache if column_exists?(:discussions, :star_count_cache)
    remove_column :discussions, :likes if column_exists?(:discussions, :likes)
  end

  def down
    create_table :stars do |t|
      t.string :votable_type, null: false
      t.integer :votable_id, null: false
      t.string :voter_identifier
      t.string :star_type, default: "star"
      t.integer :vote_type, default: 1, null: false
      t.timestamps

      t.index [ :votable_type, :votable_id ], name: "index_stars_on_votable"
    end

    add_column :discussions, :star_count_cache, :integer, default: 0
    add_column :discussions, :likes, :integer, default: 0, null: false
  end
end
