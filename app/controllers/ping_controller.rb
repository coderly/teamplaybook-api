class PingController < ApplicationController

  def index
    response = {ping: "pong", current_time: Time.now.utc}
    response[:team_name] = current_team.name if current_team.present?
    render json: response
  end

end