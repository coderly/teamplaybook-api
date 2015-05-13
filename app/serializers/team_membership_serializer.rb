class TeamMembershipSerializer < ActiveModel::Serializer
  attributes :id, :email, :role

  belongs_to :user
  belongs_to :team
end