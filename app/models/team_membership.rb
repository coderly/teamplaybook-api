require 'errors/cannot_remove_owner_from_team_error'

class TeamMembership < ActiveRecord::Base
  belongs_to :team
  belongs_to :user
  validate :limit_role_to_invitee_for_unregistered_users,
    :limit_role_to_owner_for_team_owner

  before_destroy :prevent_owner_membership_deletion

  enum role: { invitee: 0, member: 1, admin: 2, owner: 3 }

  def limit_role_to_invitee_for_unregistered_users
    if user.blank? and not invitee?
      errors.add(:role, "Cannot change role from invitee until user has registered.")
    end
  end

  def limit_role_to_owner_for_team_owner
    if team.present? and team.owner.present? and user == team.owner and !owner?
      errors.add(:role, "Cannot change role from owner.")
    end
  end

  def prevent_owner_membership_deletion
    raise CannotRemoveOwnerFromTeam if owner?
  end
end
