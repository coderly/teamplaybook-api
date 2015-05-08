class CurrentUserSerializer < ActiveModel::Serializer
  attributes :id, :email, :authentication_token, :role

  def role
    @options[:current_team_membership].roles.first.to_s unless @options[:current_team_membership].blank?
  end
end