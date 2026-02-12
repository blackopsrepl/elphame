class AddCustomizationToRealms < ActiveRecord::Migration[8.1]
  def change
    add_column :realms, :icon, :string, default: ""
    add_column :realms, :color, :string, default: "#7e22ce"
    add_column :realms, :rules, :text, default: ""
  end
end
