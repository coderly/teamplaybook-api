module TeamPlaybook
  module Scenario
    class DemoteTeamMembership

      def call(team_membership_params)
        team_membership = TeamMembership.find(team_membership_params[:id])
        team_membership.roles = [:member]
        team_membership.save

        team_membership
      end
    end
  end
end
