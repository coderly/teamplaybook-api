require 'cancan'

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

  def promote
    if has_team_subdomain?
      authorize! :promote, TeamMembership
      team_membership = TeamPlaybook::Scenario::PromoteTeamMembership.new.call(current_team_membership)
      if team_membership.valid?
        render json: team_membership, status: 200
      else
        render json: {error: team_membership.errors.full_messages.to_sentence}, status: :unprocessable_entity
      end
    else
      forbidden
    end
  end

  def demote
    if has_team_subdomain?
      authorize! :demote, TeamMembership
      team_membership = TeamPlaybook::Scenario::DemoteTeamMembership.new.call(current_team_membership)
      if team_membership.valid?
        render json: team_membership, status: 200
      else
        render json: {error: team_membership.errors.full_messages.to_sentence}, status: :unprocessable_entity
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
    params.require(:data).permit(:email)
  end

  def current_team_membership
    TeamMembership.find(params[:id])
  end
end
