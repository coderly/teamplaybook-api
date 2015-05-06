class TeamMembership < ActiveRecord::Base
  belongs_to :team
  belongs_to :user
  validate :role_must_be_invitee_if_no_user,
    :role_must_be_owner_if_user_equals_team_owner

  include RoleModel
  roles :invitee, :member, :admin, :owner

  def role_must_be_invitee_if_no_user
    if user.blank? and !has_role? :invitee
      errors.add(:role, "Cannot change role from invitee until user has registered.")
    end
  end

  def role_must_be_owner_if_user_equals_team_owner
    if team.present? and team.owner.present? and user == team.owner and !has_role? :owner
      errors.add(:role, "Cannot change role from owner.")
    end
  end
end
