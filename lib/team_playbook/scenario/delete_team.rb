module TeamPlaybook
  module Scenario
    class DeleteTeam
      def call(team:)
        team.destroy
      end
    end
  end
end
