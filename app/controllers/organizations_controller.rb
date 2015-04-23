class OrganizationsController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  def create
    organization = Organization.new(organization_params)
    organization.user = current_user
    if organization.save
      render json: organization, status: 200, serializer: OrganizationSerializer
    else
      render json: {error: organization.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  def show
    render json: @organization, status: 200, serializer: OrganizationSerializer
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :subdomain)
  end
end