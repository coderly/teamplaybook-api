require 'team_playbook/scenario/create_page'
require 'team_playbook/scenario/update_page'
require 'team_playbook/scenario/remove_page'


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

  def update
    if has_team_subdomain?
      authorize! :update, current_page
      page = TeamPlaybook::Scenario::UpdatePage.new.call(page: current_page, page_params: page_params)
      if page.valid?
        render json: page, status: 200
      else
        render json: {error: page.errors.full_messages.to_sentence}, status: :unprocessable_entity
      end
    else
      forbidden
    end
  end

  def destroy
    authorize! :destroy, current_page

    TeamPlaybook::Scenario::RemovePage.new.call(current_page)
    render :nothing => true, :status => 204
  end

  private

  def page_params
    params.require(:data).permit(:title, :body, :parent_id)
  end

  def current_page
    Page.find(params[:id])
  end

end
