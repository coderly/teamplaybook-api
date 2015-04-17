class ApplicationController < ActionController::API
  include ActionView::Layouts
  include ActionController::ImplicitRender
  
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  before_filter :fetch_organization

  NON_ORGANIZATION_SUBDOMAINS = [:www]

  protected

  def fetch_organization
    @organization = Organization.find_by! subdomain: request.subdomain if has_organization_subdomain?
  end

  private

  def has_organization_subdomain?
    request.subdomain.present? && !Settings.non_organization_subdomains.include?(request.subdomain)
  end

  def not_found
    render json: {error: "Not Found"}, status: :not_found
  end

end
