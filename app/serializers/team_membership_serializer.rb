class TeamMembershipSerializer < ActiveModel::Serializer
  attributes :id, :email

  belongs_to :user
  belongs_to :team
end