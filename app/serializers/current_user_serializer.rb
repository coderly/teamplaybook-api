class CurrentUserSerializer < ActiveModel::Serializer
  attributes :id, :email, :authentication_token, :role

  has_one :current_team_membership, serializer: TeamMembershipSerializer

  def current_team_membership
    @options[:current_team_membership] unless @options[:current_team_membership].blank?
  end

  def role
    current_team_membership.role unless current_team_membership.blank?
  end
end