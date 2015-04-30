require 'team_playbook/scenario/create_team'
require 'team_playbook/scenario/create_team'
require 'errors/credit_card_required_error'

class TeamsController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  rescue_from CreditCardRequiredError, with: :credit_card_required

  def create
    team = TeamPlaybook::Scenario::CreateTeam.new.call(team_params: team_params, owner: current_user)
    if team.persisted?
      render json: team, status: 200
    else
      render json: {error: team.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  def show
    render json: @team, status: 200
  end

  def change_plan
    plan = Plan.find_by_slug! params[:plan_slug]
    TeamPlaybook::Scenario::ChangePlanForTeam.new.call(@team, plan)
    render json: plan, status: 200
  end

  private

  def team_params
    params.require(:data).permit(:name, :subdomain)
  end

  def credit_card_required
    render json: {error: "A credit card is require for this action."}, status: :unprocessable_entity
  end
end