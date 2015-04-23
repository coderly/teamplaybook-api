require 'team_playbook/scenario/create_organization_user'
require 'cancan'

class OrganizationUsersController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  def create
    authorize! :create, OrganizationUser
    organization_user = TeamPlaybook::Scenario::CreateOrganizationUser.new.call(organization_user_params, @organization)
    if organization_user.persisted?
      render json: organization_user, status: 200
    else
      render json: {error: organization_user.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  private

  def organization_user_params
    params.require(:data).permit(:email, :subdomain)
  end
end
