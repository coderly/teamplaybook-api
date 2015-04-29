class Ability
  include CanCan::Ability

  def initialize(user, team)
    if team.owner ==  user
      can :manage, TeamMembership, team: team
    end
  end
end