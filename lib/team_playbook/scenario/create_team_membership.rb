module TeamPlaybook
  module Scenario
    class CreateTeamMembership

      def call(team, team_membership_params)
        team_membership = create_team_membership(team_membership_params, team)
        return team_membership unless team_membership.persisted?

        connect_and_notify_user(team_membership)
        team_membership
      end

      private

      def create_team_membership(team_membership_params, team)
        team_membership_params[:team_id] = team.id
        team_membership_params[:role] = :invitee
        return TeamMembership.create(team_membership_params)
      end

      def connect_and_notify_user(team_membership)
        connect_user_to_team(team_membership)
        send_team_membership_email(team_membership)
      end

      def connect_user_to_team(team_membership)
        user = User.find_by_email(team_membership.email)

        user_is_owner = user.present? && team_membership.team.owner == user
        user_is_member = user.present? && team_membership.team.owner != user

        team_membership.update_attributes(user_id: user.id, role: :owner) if user_is_owner
        team_membership.update_attributes(user_id: user.id, role: :member) if user_is_member
      end

      def send_team_membership_email(team_membership)
        TeamMembershipMailer.team_membership_email(team_membership).deliver_now
      end
    end
  end
end
