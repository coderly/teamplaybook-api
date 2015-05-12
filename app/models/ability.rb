class Ability
  include CanCan::Ability

  def initialize(user, team)
    if team.members.include? user
      can :manage, TeamMembership, team: team if team.owner ==  user
      can :read, TeamMembership, team: team
      can :update, TeamMembership, team: team if TeamMembership.find_by(team: team, user: user).has_any_role? :admin, :owner
    end
  end
end