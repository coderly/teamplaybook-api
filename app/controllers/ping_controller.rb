class PingController < ApplicationController

  def index
    response = {ping: "pong", current_time: Time.now.utc}
    response[:organization_name] = @organization.name if @organization.present?
    render json: response
  end

end