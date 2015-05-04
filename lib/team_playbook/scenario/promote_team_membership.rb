module TeamPlaybook
  module Scenario
    class PromoteTeamMembership

      def call(team_membership_params)
        team_membership = TeamMembership.find(team_membership_params[:id])
        team_membership.roles = [:admin]
        team_membership.save

        team_membership
      end
    end
  end
end
