class SwitchTeamMembershipRoleToSimpleInteger < ActiveRecord::Migration
  def change
    add_column :team_memberships, :role, :integer

    reversible do |dir|
      TeamMembership.all.each do |team_membership|
        dir.up {
          team_membership.invitee! if team_membership.roles_mask == 1
          team_membership.member! if team_membership.roles_mask == 2
          team_membership.admin! if team_membership.roles_mask == 4
          team_membership.owner! if team_membership.roles_mask == 8
        }

        dir.down {
          team_membership.update_attribute :roles_mask, 1 if team_membership.invitee?
          team_membership.update_attribute :roles_mask, 2 if team_membership.member?
          team_membership.update_attribute :roles_mask, 4 if team_membership.admin?
          team_membership.update_attribute :roles_mask, 8 if team_membership.owner?
        }
      end
    end

    remove_column :team_memberships, :roles_mask, :integer
  end
end
