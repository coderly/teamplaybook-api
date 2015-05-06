module TeamPlaybook
  module Scenario
    class DeleteTeamMembership

      def call(team_membership:)
        if team_membership.has_role? :owner
          result = false
        else
          team_membership.destroy
          result = true
        end

        result
      end
    end
  end
end
