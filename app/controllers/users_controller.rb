require 'team_playbook/scenario/assign_user_to_invited_organization'

class UsersController < Devise::RegistrationsController
  def create
    user = User.new(user_params)
    if user.save
      TeamPlaybook::Scenario::AssignUserToInvitedOrganizations.new.call(user)
      render json: user, status: 201, serializer: CurrentUserSerializer
    else
      warden.custom_failure!
      render json: {error: user.errors.full_messages.to_sentence}, status: 422
    end
  end

  private

  def user_params
    params.require(:data).permit(:email, :password, :password_confirmation)
  end
end