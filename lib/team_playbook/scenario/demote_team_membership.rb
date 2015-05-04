module TeamPlaybook
  module Scenario
    class DemoteTeamMembership

      def call(team_membership)
        team_membership.roles = [:member]
        team_membership.save

        team_membership
      end
    end
  end
end
