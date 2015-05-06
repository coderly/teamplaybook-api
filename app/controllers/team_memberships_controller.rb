require 'cancan'
require 'team_playbook/scenario/create_team_membership'
require 'team_playbook/scenario/update_team_membership'
require 'team_playbook/scenario/delete_team_membership'

class TeamMembershipsController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  def create
    authorize! :create, TeamMembership
    team_membership = TeamPlaybook::Scenario::CreateTeamMembership.new.call(@team, team_membership_params)
    if team_membership.persisted?
      render json: team_membership, status: 200
    else
      render json: {error: team_membership.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  def update
    if has_team_subdomain?
      authorize! :update, TeamMembership
      team_membership = TeamPlaybook::Scenario::UpdateTeamMembership.new.call(team_membership: current_team_membership, params: team_membership_params)
      if team_membership.valid?
        render json: team_membership, status: 200
      else
        render json: {error: team_membership.errors[:role].to_sentence}, status: :unprocessable_entity
      end
    else
      forbidden
    end
  end

  def destroy
    if has_team_subdomain?
      authorize! :delete, TeamMembership
      success = TeamPlaybook::Scenario::DeleteTeamMembership.new.call(team_membership: current_team_membership)
      if success
        render nothing: true, status: 204
      else
        render json: {error: "Cannot delete team owner."}, status: 405
      end
    else
      forbidden
    end
  end

  def index
    if has_team_subdomain?
      authorize! :read, TeamMembership
      render json: @team.team_memberships, status: 200
    else
      forbidden
    end
  end

  private

  def team_membership_params
    params.require(:data).permit(:email, roles: [])
  end

  def current_team_membership
    TeamMembership.find(params[:id])
  end
end
