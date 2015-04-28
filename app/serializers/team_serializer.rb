class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :subdomain, :plan_name

  belongs_to :owner
  belongs_to :plan
end