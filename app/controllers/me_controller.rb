class MeController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  def show
    render json: current_user, status: 201, serializer: CurrentUserSerializer, current_team_membership: current_team_membership
  end
end