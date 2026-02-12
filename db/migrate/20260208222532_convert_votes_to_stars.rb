class ConvertVotesToStars < ActiveRecord::Migration[8.1]
  def change
    # Rename table
    rename_table :votes, :stars

    # Remove vote_type (only positive stars)
    remove_column :stars, :vote_type, :integer

    # Add star_type for future expansion
    add_column :stars, :star_type, :string, default: 'star'

    # Keep existing polymorphic structure
    # Already has: votable_type, votable_id, voter_identifier, timestamps

    # Add index for counting
    add_index :stars, [ :votable_type, :votable_id, :star_type ]
  end
end
