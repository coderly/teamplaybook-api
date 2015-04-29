require 'team_playbook/scenario/change_plan_for_team'

module TeamPlaybook
  module Scenario
    class CreateTeam
      def call(team_params:, owner:)
        team = Team.new(team_params)
        team.owner = owner

        team.save
        subscribe_team_to_default_plan(team) if team.persisted?

        team
      end

      private

      def subscribe_team_to_default_plan(team)
        ChangePlanForTeam.new.call(team, default_plan)
      end

      def default_plan
        Plan.default_plan
      end

    end
  end
end