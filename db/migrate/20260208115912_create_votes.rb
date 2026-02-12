class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :votable, polymorphic: true, null: false
      t.integer :vote_type

      t.timestamps
    end
  end
end
