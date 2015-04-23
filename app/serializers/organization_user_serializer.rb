class OrganizationUserSerializer < ActiveModel::Serializer
  attributes :id, :email

  belongs_to :user
  belongs_to :organization
end