class TeamMembersController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  def index
    render json: @team.members, status: 200 if has_team_subdomain?
    render json: User.all, status: 200 unless has_team_subdomain?
  end
end