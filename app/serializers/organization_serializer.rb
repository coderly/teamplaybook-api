class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :name, :subdomain

  belongs_to :owner
end