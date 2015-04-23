class Ability
  include CanCan::Ability

  def initialize(user, organization)
    if organization.user ==  user
      can :manage, OrganizationUser
    end
  end
end