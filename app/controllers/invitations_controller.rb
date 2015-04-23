require 'team_playbook/scenario/create_invitation'
require 'cancan'

class InvitationsController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  def create
    authorize! :create, Invitation
    invitation = TeamPlaybook::Scenario::CreateInvitation.new.call(invitation_params, @organization)
    if invitation.persisted?
      render json: invitation, status: 200
    else
      render json: {error: invitation.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  private

  def invitation_params
    params.require(:data).permit(:email, :subdomain)
  end
end
