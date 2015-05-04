class AddRolesMaskToTeamMembership < ActiveRecord::Migration
  def change
    add_column :team_memberships, :roles_mask, :integer
    TeamMembership.all.each do |team_membership|
      team_membership.roles = [:invitee] if team_membership.user.blank?
      team_membership.roles = [:member] if team_membership.user.present?
      team_membership.roles = [:owner] if team_membership.user == team_membership.team.owner
    end
  end
end
