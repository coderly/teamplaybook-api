module TeamPlaybook
  module Scenario
    class CreateTeamMembership

      def call(team_membership_params, organization)
        team_membership = create_team_membership(team_membership_params, organization)
        return team_membership unless team_membership.persisted?

        connect_and_notify_user(team_membership)
        team_membership
      end


      private

      def create_team_membership(team_membership_params, organization)
        team_membership_params[:organization_id] = organization.id
        return TeamMembership.create(team_membership_params)
      end

      def connect_and_notify_user(team_membership)
        connect_user_to_organization(team_membership)
        send_team_membership_email(team_membership)
      end

      def connect_user_to_organization(team_membership)
        user = User.find_by_email(team_membership.email)
        team_membership.update_attribute :user_id, user.id if user.present?
      end

      def send_team_membership_email(team_membership)
        TeamMembershipMailer.team_membership_email(team_membership).deliver_now
      end

    end
  end
end