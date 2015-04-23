class Ability
  include CanCan::Ability

  def initialize(user, organization)
    if organization.owner ==  user
      can :manage, OrganizationUser
    end
  end
end