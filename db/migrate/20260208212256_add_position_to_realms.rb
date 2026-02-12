class AddPositionToRealms < ActiveRecord::Migration[8.1]
  def change
    add_column :realms, :position, :integer, default: 99

    # Set positions for existing realms
    reversible do |dir|
      dir.up do
        # Operational realm first, then the five symbolic realms
        realm_order = {
          'the-writ' => 0,
          'the-threshold' => 1,
          'forbidden-knowledge' => 2,
          'the-dream-archive' => 3,
          'the-dark-mirror' => 4,
          'random' => 5
        }

        realm_order.each do |slug, position|
          execute "UPDATE realms SET position = #{position} WHERE slug = '#{slug}'"
        end
      end
    end
  end
end
