module TeamPlaybook
  module Scenario
    class PromoteTeamMembership

      def call(team_membership)
        team_membership.roles = [:admin]
        team_membership.save

        team_membership
      end
    end
  end
end
