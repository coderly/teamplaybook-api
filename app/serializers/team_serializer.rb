class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :subdomain

  belongs_to :owner
end