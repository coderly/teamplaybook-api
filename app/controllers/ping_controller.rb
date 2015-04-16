class PingController < ApplicationController

  def index
    response = {"ping" => "pong"}
    response[:organization_name] = @organization.name if @organization.present?
    render json: response
  end

end
