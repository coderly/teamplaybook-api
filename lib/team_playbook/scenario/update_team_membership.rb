module TeamPlaybook
  module Scenario
    class UpdateTeamMembership

      def call(team_membership:, params:)
        team_membership.role = params[:role] if params.key? :role
        team_membership.save

        team_membership
      end
    end
  end
end
