module TeamPlaybook
  module Scenario
    class AssignUserToInvitedOrganizations

      def call(user)
        organization_users = organization_users_for(user)
        organization_users.each do |organization_user|
          connect_organization_user_to_user(organization_user, user)
        end
      end

      private

      def organization_users_for(user)
        OrganizationUser.where(email: user.email)
      end

      def connect_organization_user_to_user(organization_user, user)
        organization_user.update_attribute :user, user
      end
    end
  end
end