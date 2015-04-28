require 'team_playbook/scenario/subscribe_team_to_plan'

module TeamPlaybook
  module Scenario
    class CreateTeam
      def call(team_params:, owner:, plan_slug: nil)
        team = Team.new(team_params)
        team.owner = owner

        team.save
        subscribe_team_to_plan(team, plan_slug) if team.persisted?

        team
      end

      private

      def subscribe_team_to_plan(team, plan_slug)
        SubscribeTeamToPlan.new.call(team, plan_slug)
      end
    end
  end
end