require 'rails_helper'
require 'team_playbook/scenario/promote_team_membership'

module TeamPlaybook
  module Scenario
    describe PromoteTeamMembership do
      it "should promote a membership with 'member' role to 'admin'" do
        user = create(:user)
        team = create(:team)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, roles: [:member])

        team_membership = PromoteTeamMembership.new.call(team_membership)

        expect(team_membership.has_role? :admin).to be true
        expect(team_membership.valid?).to be true
      end

      it "should keep the 'admin' role for membership with 'admin' role" do
        user = create(:user)
        team = create(:team)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, roles: [:admin])

        team_membership = PromoteTeamMembership.new.call(team_membership)

        expect(team_membership.has_role? :admin).to be true
        expect(team_membership.valid?).to be true
      end

      it "should return an invalid record for team_membership with role 'invitee'" do
        team = create(:team)

        team_membership = create(:team_membership, team: team, email: "test@example.com", roles: [:invitee])

        team_membership = PromoteTeamMembership.new.call(team_membership)

        expect(team_membership.valid?).to be false
      end

      it "should return an invalid record for team_membership with role 'owner'" do
        owner = create(:user)
        team = create(:team, owner: owner)

        team_membership = create(:team_membership, user: owner, team: team, email: owner.email, roles: [:owner])

        team_membership = PromoteTeamMembership.new.call(team_membership)

        expect(team_membership.valid?).to be false
      end
    end
  end
end
