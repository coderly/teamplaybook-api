module TeamPlaybook
  module Scenario
    class UpdateTeamMembership

      def call(team_membership:, params:)
        team_membership.roles = params[:roles] if params.key? :roles
        team_membership.save

        team_membership
      end
    end
  end
end
