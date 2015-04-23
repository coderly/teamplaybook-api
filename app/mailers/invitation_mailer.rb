class InvitationMailer < ApplicationMailer
  def invitation_email(invitation)
    @organization = invitation.organization
    @invitation = invitation
    @user = invitation.user
    @url  = "http://#{@organization.subdomain}.#{ENV['WEB_APPLICATION_DOMAIN']}"
    @url  = @url + "/sign_up" unless @user.present?
    mail(to: @invitation.email, subject: "You have been invited to #{@organization.name} on Team Playbook")
  end
end
