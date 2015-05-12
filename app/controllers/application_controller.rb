class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions

  rescue_from CanCan::AccessDenied, with: :not_authorized
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  before_filter :fetch_team

  protected

  def fetch_team
    @current_team = Team.find_by_subdomain!(request.subdomain) if has_team_subdomain?
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, current_team)
  end

  def current_team
    @current_team ||= nil
  end

  def current_team_membership
    TeamMembership.find_by(user: current_user, team: current_team) if current_team.present?
  end

  private

  def has_team_subdomain?
    has_subdomain? && !has_reserved_subdomain?
  end

  def not_found
    render json: {error: "Not Found"}, status: :not_found
  end

  def not_authorized
    render json: {error: "Not Authorized"}, status: :unauthorized
  end

  def forbidden
    render json: {error: "Forbidden"}, status: :forbidden
  end

  def has_subdomain?
    request.subdomain.present?
  end

  def has_reserved_subdomain?
    Settings.reserved_subdomains.include?(request.subdomain)
  end
end
