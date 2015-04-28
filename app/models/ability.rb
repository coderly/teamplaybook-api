class Ability
  include CanCan::Ability

  def initialize(user, team)
    if team.owner ==  user
      can :manage, TeamMembership
    end
  end
end