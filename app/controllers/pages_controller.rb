require 'team_playbook/scenario/create_page'

class PagesController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  def index
    authorize! :read, Page

    render json: Page.for_team(current_team), status: 200
  end

  def index
    authorize! :create, Page

    render json: Page.for_team(current_team), status: 200
  end

  def create
    authorize! :create, Page
    page = TeamPlaybook::Scenario::CreatePage.new.call(team: current_team, page_params: page_params)
    if page.persisted?
      render json: page, status: 200
    else
      render json: {error: page.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  private

  def page_params
    params.require(:data).permit(:title, :body, :parent_id)
  end

end