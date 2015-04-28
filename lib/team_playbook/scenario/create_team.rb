module TeamPlaybook
  module Scenario
    class CreateTeam
      def call(team_params:, owner:)
        team = Team.new(team_params)
        team.owner = owner

        team.save

        team
      end
    end
  end
end