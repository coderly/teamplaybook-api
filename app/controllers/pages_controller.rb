class PagesController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  def index
    authorize! :read, Page

    render json: Page.for_team(current_team), status: 200
  end

end