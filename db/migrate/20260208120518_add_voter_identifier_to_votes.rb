class AddVoterIdentifierToVotes < ActiveRecord::Migration[8.1]
  def change
    add_column :votes, :voter_identifier, :string
  end
end
