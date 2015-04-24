class RenameOrganizationsToTeams < ActiveRecord::Migration
  def change
    rename_table :organizations, :teams
  end
end