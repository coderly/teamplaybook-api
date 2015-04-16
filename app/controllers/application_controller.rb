class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  before_filter :fetch_organization

  NON_ORGANIZATION_SUBDOMAINS = [:www]

  protected

  def fetch_organization
    @organization = Organization.find_by! subdomain: request.subdomain if has_organization_subdomain?
  end

  private

  def has_organization_subdomain?
    request.subdomain.present? && !NON_ORGANIZATION_SUBDOMAINS.include?(request.subdomain.to_sym)
  end

  def not_found
    render json: {error: "Not Found"}, status: :not_found
  end

end
