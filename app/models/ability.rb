class Ability
  include CanCan::Ability

  def initialize(user, team)
    if team.owner ==  user
      can :manage, TeamMembership, team: team
    end
    if team.members.include? user
      can :read, TeamMembership, team: team
      if TeamMembership.find_by(team: team, user: user).has_any_role? :admin, :owner
        can :update, TeamMembership, team: team
      end
    end
  end
end