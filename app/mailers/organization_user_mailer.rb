class OrganizationUserMailer < ApplicationMailer
  def organization_user_email(organization_user)
    @organization = organization_user.organization
    @organization_user = organization_user
    @user = organization_user.user
    @url  = "http://#{@organization.subdomain}.#{ENV['WEB_APPLICATION_DOMAIN']}"
    @url  = @url + "/sign_up" unless @user.present?
    mail(to: @organization_user.email, subject: "You have been invited to #{@organization.name} on Team Playbook")
  end
end