module TeamPlaybook
  module Scenario
    class AssignUserToInvitedOrganizations

      def call(user)
        invitations = invitations_for(user)
        invitations.each do |invitation|
          connect_invitation_to_user(invitation, user)
        end
      end

      private

      def invitations_for(user)
        Invitation.where(email: user.email)
      end

      def connect_invitation_to_user(invitation, user)
        invitation.update_attribute :user, user
      end


    end
  end
end