class UsersController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  team_subdomain_only :index

  def index
    authorize! :read, TeamMembership
    render json: current_team.members, status: 200
  end
end