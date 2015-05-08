class CurrentUserSerializer < ActiveModel::Serializer
  attributes :id, :email, :authentication_token, :role

  belongs_to :current_team_membership, class_name: "TeamMembership"

  def role
    @options[:current_team_membership].roles.first.to_s unless @options[:current_team_membership].blank?
  end

  def current_team_membership
    @options[:current_team_membership] unless @options[:current_team_membership].blank?
  end

end