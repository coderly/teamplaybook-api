class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions

  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  before_filter :fetch_organization

  protected

  def fetch_organization
    @organization = Organization.find_by_subdomain!(request.subdomain) if has_organization_subdomain?
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, @organization)
  end

  private

  def has_organization_subdomain?
    has_subdomain? && !has_non_organization_subdomain?
  end

  def not_found
    render json: {error: "Not Found"}, status: :not_found
  end

  def has_subdomain?
    request.subdomain.present?
  end

  def has_non_organization_subdomain?
    Settings.non_organization_subdomains.include?(request.subdomain)
  end



end
