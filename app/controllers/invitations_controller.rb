require 'team_playbook/scenario/create_invitation'

class InvitationsController < ApplicationController
  def create
    invitation = TeamPlaybook::Scenario::CreateInvitation.new.call(invitation_params, organization)
    if invitation.persisted?
      render json: invitation, status: 200
    else
      render json: {error: invitation.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email, :subdomain)
  end
end
