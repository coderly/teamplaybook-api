class TokensController < Devise::SessionsController

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)

    render json: resource, status: 201
  end

end