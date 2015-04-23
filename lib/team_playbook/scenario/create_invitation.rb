module TeamPlaybook
  module Scenario
    class CreateInvitation

      def call(invitation_params, organization)
        invitation = create_invitation(invitation_params, organization)
        return invitation unless invitation.persisted?

        send_invitation_to_user(invitation)
        invitation
      end


      private

      def create_invitation(invitation_params, organization)
        invitation_params[:organization_id] = organization.id
        return Invitation.create(invitation_params)
      end

      def send_invitation_to_user(invitation)
        assign_invitation(invitation)
        send_invitation_email(invitation)
      end

      def assign_invitation(invitation)
        user = User.find_by_email(invitation.email)
        invitation.update_attribute :user_id, user.id if user.present?
      end

      def send_invitation_email(invitation)
        InvitationMailer.invitation_email(invitation).deliver_now
      end

    end
  end
end