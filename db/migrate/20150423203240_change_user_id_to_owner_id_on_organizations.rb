class ChangeUserIdToOwnerIdOnOrganizations < ActiveRecord::Migration
  def change
    rename_column(:organizations, :user_id, :owner_id)
  end
end
