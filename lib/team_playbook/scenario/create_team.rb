require 'team_playbook/scenario/change_plan_for_team'
require 'team_playbook/scenario/create_team_membership'

module TeamPlaybook
  module Scenario
    class CreateTeam
      def call(team_params:, owner:)
        team = Team.new(team_params)
        team.owner = owner

        team.save

        create_owner_team_membership(team) if team.persisted?
        subscribe_team_to_default_plan(team) if team.persisted?

        team
      end

      private

      def create_owner_team_membership(team)
        CreateTeamMembership.new.call(team, { email: team.owner.email })
      end

      def subscribe_team_to_default_plan(team)
        ChangePlanForTeam.new.call(team, default_plan)
      end

      def default_plan
        Plan.default_plan
      end

    end
  end
end