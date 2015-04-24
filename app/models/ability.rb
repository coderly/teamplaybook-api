class Ability
  include CanCan::Ability

  def initialize(user, organization)
    if organization.owner ==  user
      can :manage, TeamMembership
    end
  end
end