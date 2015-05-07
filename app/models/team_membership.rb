class TeamMembership < ActiveRecord::Base
  belongs_to :team
  belongs_to :user
  validate :limit_role_to_invitee_for_unregistered_users,
    :limit_role_to_owner_for_team_owners

  include RoleModel
  roles :invitee, :member, :admin, :owner

  def limit_role_to_invitee_for_unregistered_users
    if user.blank? and !has_role? :invitee
      errors.add(:role, "Cannot change role from invitee until user has registered.")
    end
  end

  def limit_role_to_owner_for_team_owners
    if team.present? and team.owner.present? and user == team.owner and !has_role? :owner
      errors.add(:role, "Cannot change role from owner.")
    end
  end
end
