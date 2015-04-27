class PingController < ApplicationController

  def index
    response = {ping: "pong", current_time: Time.now.utc}
    response[:team_name] = @team.name if @team.present?
    render json: response
  end

end