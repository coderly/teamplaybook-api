module TeamPlaybook
  module Scenario
    class ArchiveTeam
      def call(team:)
        team.archived!
      end
    end
  end
end
