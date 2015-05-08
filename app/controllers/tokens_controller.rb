class TokensController < Devise::SessionsController

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)

    render json: resource, status: 201, serializer: CurrentUserSerializer, current_team_membership: current_team_membership
  end

  private

  def current_team_membership
    TeamMembership.find_by(user: current_user, team: current_team) if current_team.present?
  end
end