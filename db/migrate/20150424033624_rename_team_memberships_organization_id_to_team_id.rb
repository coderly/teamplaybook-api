class RenameTeamMembershipsOrganizationIdToTeamId < ActiveRecord::Migration
  def change
    rename_column :team_memberships, :organization_id, :team_id
  end
end
