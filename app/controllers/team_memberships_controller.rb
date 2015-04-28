require 'team_playbook/scenario/create_team_membership'
require 'cancan'

class TeamMembershipsController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  def create
    authorize! :create, TeamMembership
    team_membership = TeamPlaybook::Scenario::CreateTeamMembership.new.call(@team, team_membership_params)
    if team_membership.persisted?
      render json: team_membership, status: 20
    else
      render json: {error: team_membership.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  private

  def team_membership_params
    params.require(:data).permit(:email)
  end
end
