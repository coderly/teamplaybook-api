class TeamMembership < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  include RoleModel
  roles :invitee, :member, :admin, :owner
end