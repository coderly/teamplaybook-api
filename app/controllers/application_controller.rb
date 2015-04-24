class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions

  rescue_from CanCan::AccessDenied, with: :not_authorized
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  
  before_filter :fetch_team

  protected

  def fetch_team
    @team = Team.find_by_subdomain!(request.subdomain) if has_team_subdomain?
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, @team)
  end

  private

  def has_team_subdomain?
    has_subdomain? && !has_non_team_subdomain?
  end

  def not_found
    render json: {error: "Not Found"}, status: :not_found
  end

  def not_authorized
    render json: {error: "Not Authorized"}, status: :unauthorized
  end

  def has_subdomain?
    request.subdomain.present?
  end

  def has_non_team_subdomain?
    Settings.non_team_subdomains.include?(request.subdomain)
  end
end
