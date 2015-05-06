require 'rails_helper'
require 'team_playbook/scenario/update_team_membership'

module TeamPlaybook
  module Scenario
    describe UpdateTeamMembership do
      it "should allow a membership with 'admin' role to  be changed to 'member'" do
        user = create(:user)
        team = create(:team)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, roles: [:admin])

        team_membership = UpdateTeamMembership.new.call(team_membership: team_membership, params: {roles: [:member]})

        expect(team_membership.has_role? :member).to be true
        expect(team_membership.valid?).to be true
      end

      it "should allow a membership with 'member' role to be changed to 'admin'" do
        user = create(:user)
        team = create(:team)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, roles: [:member])

        team_membership = UpdateTeamMembership.new.call(team_membership: team_membership, params: {roles: [:admin]})

        expect(team_membership.has_role? :admin).to be true
        expect(team_membership.valid?).to be true
      end

      it "should should return an invalid record if team membership role is 'invitee', there is no user and an attempt is made to change it" do
        team = create(:team)

        team_membership = create(:team_membership, team: team, email: "test@example.com", roles: [:invitee])

        team_membership = UpdateTeamMembership.new.call(team_membership: team_membership, params: {roles: [:member]})

        expect(team_membership.valid?).to be false
      end

      it "should return an invalid record if team membership role is 'owner' and an attempt is made to change it" do
        owner = create(:user)
        team = create(:team, owner: owner)

        team_membership = create(:team_membership, user: owner, team: team, email: owner.email, roles: [:owner])

        team_membership = UpdateTeamMembership.new.call(team_membership: team_membership, params: {roles: [:member]})

        expect(team_membership.valid?).to be false
      end
    end
  end
end
