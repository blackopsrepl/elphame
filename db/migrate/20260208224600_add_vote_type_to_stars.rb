class AddVoteTypeToStars < ActiveRecord::Migration[8.1]
  def change
    add_column :stars, :vote_type, :integer, default: 1, null: false

    # Backfill existing stars as upvotes (+1)
    reversible do |dir|
      dir.up do
        execute "UPDATE stars SET vote_type = 1 WHERE vote_type IS NULL"
      end
    end
  end
end
