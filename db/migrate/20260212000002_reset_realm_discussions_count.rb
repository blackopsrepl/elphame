class ResetRealmDiscussionsCount < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE realms
      SET discussions_count = (
        SELECT COUNT(*) FROM discussions WHERE discussions.realm_id = realms.id
      )
    SQL
  end

  def down
    # Counter cache will be maintained naturally by Rails going forward
  end
end
