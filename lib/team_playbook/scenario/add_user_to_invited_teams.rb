module TeamPlaybook
  module Scenario
    class AddUserToInvitedTeams

      def call(user)
        team_memberships = team_memberships_for(user)
        team_memberships.each do |team_membership|
          connect_team_membership_to_user(team_membership, user)
        end
      end

      private

      def team_memberships_for(user)
        TeamMembership.where(email: user.email)
      end

      def connect_team_membership_to_user(team_membership, user)
        team_membership.update_attribute :user, user
      end
    end
  end
end