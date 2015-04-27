class TeamMembershipMailer < ApplicationMailer
  def team_membership_email(team_membership)
    @team = team_membership.team
    @team_membership = team_membership
    @user = team_membership.user
    @url  = "http://#{@team.subdomain}.#{ENV['WEB_APPLICATION_DOMAIN']}"
    @url  = @url + "/sign_up" unless @user.present?
    mail(to: @team_membership.email, subject: "You have been invited to #{@team.name} on Team Playbook")
  end
end