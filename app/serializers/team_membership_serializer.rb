class TeamMembershipSerializer < ActiveModel::Serializer
  attributes :id, :email, :roles

  belongs_to :user
  belongs_to :team
end