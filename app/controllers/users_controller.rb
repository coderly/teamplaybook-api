class UsersController < Devise::RegistrationsController
  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: 201, serializer: CurrentUserSerializer
    else
      warden.custom_failure!
      render json: {error: user.errors.full_messages.to_sentence}, status: 422
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end