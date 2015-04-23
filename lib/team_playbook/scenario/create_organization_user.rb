module TeamPlaybook
  module Scenario
    class CreateOrganizationUser

      def call(organization_user_params, organization)
        organization_user = create_organization_user(organization_user_params, organization)
        return organization_user unless organization_user.persisted?

        connect_and_notify_user(organization_user)
        organization_user
      end


      private

      def create_organization_user(organization_user_params, organization)
        organization_user_params[:organization_id] = organization.id
        return OrganizationUser.create(organization_user_params)
      end

      def connect_and_notify_user(organization_user)
        connect_user_to_organization(organization_user)
        send_organization_user_email(organization_user)
      end

      def connect_user_to_organization(organization_user)
        user = User.find_by_email(organization_user.email)
        organization_user.update_attribute :user_id, user.id if user.present?
      end

      def send_organization_user_email(organization_user)
        OrganizationUserMailer.organization_user_email(organization_user).deliver_now
      end

    end
  end
end