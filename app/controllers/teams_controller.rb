require 'team_playbook/scenario/create_team'
require 'team_playbook/scenario/delete_team'
require 'team_playbook/scenario/change_plan_for_team'
require 'team_playbook/scenario/add_card_to_team'
require 'errors/credit_card_required_error'

class TeamsController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  rescue_from CreditCardRequiredError, with: :credit_card_required

  team_subdomain_only [:show, :destroy, :change_plan]

  def create
    team = TeamPlaybook::Scenario::CreateTeam.new.call(team_params: team_params, owner: current_user)
    if team.persisted?
      render json: team, status: 200
    else
      render json: {error: team.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  def show
    authorize! :read, current_team
    render json: current_team, status: 200
  end

  def destroy
    authorize! :destroy, current_team
    TeamPlaybook::Scenario::DeleteTeam.new.call(team: current_team)
    render nothing: true, status: 204
  end

  def change_plan
    plan = Plan.find_by_slug! params[:plan_slug]
    TeamPlaybook::Scenario::AddCardToTeam.new.call(current_team, params[:card_token]) if params[:card_token].present?
    TeamPlaybook::Scenario::ChangePlanForTeam.new.call(current_team, plan)
    render json: plan, status: 200
  end

  private

  def team_params
    params.require(:data).permit(:name, :subdomain)
  end

  def credit_card_required
    render json: {error: "A credit card is required for a paid plan."}, status: :unprocessable_entity
  end
end
