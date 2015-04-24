class TeamMembershipMailer < ApplicationMailer
  def team_membership_email(team_membership)
    @organization = team_membership.organization
    @team_membership = team_membership
    @user = team_membership.user
    @url  = "http://#{@organization.subdomain}.#{ENV['WEB_APPLICATION_DOMAIN']}"
    @url  = @url + "/sign_up" unless @user.present?
    mail(to: @team_membership.email, subject: "You have been invited to #{@organization.name} on Team Playbook")
  end
end