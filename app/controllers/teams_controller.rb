class TeamsController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  def create
    team = Team.new(team_params)
    team.owner = current_user
    if team.save
      render json: team, status: 200
    else
      render json: {error: team.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  def show
    render json: @team, status: 200
  end

  private

  def team_params
    params.require(:data).permit(:name, :subdomain)
  end
end