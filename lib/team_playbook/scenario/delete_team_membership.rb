module TeamPlaybook
  module Scenario
    class DeleteTeamMembership
      def call(team_membership:)
        team_membership.destroy
      end
    end
  end
end
