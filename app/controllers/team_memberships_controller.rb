require 'cancan'
require 'team_playbook/scenario/create_team_membership'
require 'team_playbook/scenario/update_team_membership'
require 'team_playbook/scenario/delete_team_membership'
require 'errors/cannot_remove_owner_from_team_error'

class TeamMembershipsController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  team_subdomain_only :all

  def create
    authorize! :create, TeamMembership
    team_membership = TeamPlaybook::Scenario::CreateTeamMembership.new.call(current_team, team_membership_params)
    if team_membership.persisted?
      render json: team_membership, status: 200
    else
      render json: {error: team_membership.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  def update
    authorize! :update, current_team_membership
    team_membership = TeamPlaybook::Scenario::UpdateTeamMembership.new.call(team_membership: current_team_membership, params: team_membership_params)
    if team_membership.valid?
      render json: team_membership, status: 200
    else
      render json: {error: team_membership.errors[:role].to_sentence}, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, current_team_membership
    begin
      TeamPlaybook::Scenario::DeleteTeamMembership.new.call(team_membership: current_team_membership)
      render nothing: true, status: 204
    rescue CannotRemoveOwnerFromTeam
      render json: {error: "Cannot remove team owner from team."}, status: 405
    end
  end

  def index
    authorize! :read, TeamMembership
    render json: current_team.team_memberships, status: 200
  end

  def show
    authorize! :read, TeamMembership
    render json: current_team_membership, status: 200
  end

  private

  def team_membership_params
    params.require(:data).permit(:email, :role)
  end

  def current_team_membership
    TeamMembership.find(params[:id])
  end
end
