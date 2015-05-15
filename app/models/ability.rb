class Ability
  include CanCan::Ability

  def initialize(user, team)
    if team.members.include? user

      current_users_team_membership_in_current_team = TeamMembership.find_by(team: team, user: user)

      can :destroy, Team, owner: user

      can :create, TeamMembership, team: team if team.owner ==  user
      can :read, TeamMembership, team: team
      can :update, TeamMembership, team: team if current_users_team_membership_in_current_team.admin? or current_users_team_membership_in_current_team.owner?
      can :destroy, TeamMembership, team: team if (team.owner === user)
      can :destroy, TeamMembership, team: team, user: user unless current_users_team_membership_in_current_team.owner?
    end
  end
end