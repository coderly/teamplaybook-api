class CurrentUserSerializer < ActiveModel::Serializer
  attributes :id, :email, :authentication_token
end