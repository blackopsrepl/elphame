class CreateStarRatingsSystem < ActiveRecord::Migration[8.1]
  def change
    # New star_ratings table — per-post, per-user, 0-5 in 0.5 increments
    create_table :star_ratings do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :rating, precision: 2, scale: 1, null: false, default: 0.0
      t.timestamps

      t.index [ :post_id, :user_id ], unique: true, name: "idx_star_ratings_post_user"
    end

    # Cache columns on posts
    add_column :posts, :star_total_cache, :decimal, precision: 8, scale: 1, default: 0.0, null: false
    add_column :posts, :star_count_cache, :integer, default: 0, null: false

    # Cache column on discussions (sum of all post stars)
    add_column :discussions, :total_stars, :decimal, precision: 10, scale: 1, default: 0.0, null: false
  end
end
