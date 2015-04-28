class UsersController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  def index
    if has_team_subdomain?
      authorize! :manage, TeamMembership
      render json: @team.members, status: 200
    else
      forbidden
    end
  end
end