require 'rails_helper'
require 'team_playbook/scenario/update_team_membership'

module TeamPlaybook
  module Scenario
    describe UpdateTeamMembership do
      it "should allow a membership with 'admin' role to  be changed to 'member'" do
        user = create(:user)
        team = create(:team)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, role: :admin)

        team_membership = UpdateTeamMembership.new.call(team_membership: team_membership, params: {role: :member})

        expect(team_membership.member?).to be true
        expect(team_membership.valid?).to be true
      end

      it "should allow a membership with 'member' role to be changed to 'admin'" do
        user = create(:user)
        team = create(:team)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, role: :member)

        team_membership = UpdateTeamMembership.new.call(team_membership: team_membership, params: {role: :admin})

        expect(team_membership.admin?).to be true
        expect(team_membership.valid?).to be true
      end

      it "should should return an invalid record if team membership role is 'invitee', there is no user and an attempt is made to change it" do
        team = create(:team)

        team_membership = create(:team_membership, team: team, email: "test@example.com", role: :invitee)

        team_membership = UpdateTeamMembership.new.call(team_membership: team_membership, params: {role: :member})

        expect(team_membership.valid?).to be false
      end

      it "should return an invalid record if team membership role is 'owner' and an attempt is made to change it" do
        owner = create(:user)
        team = create(:team, owner: owner)

        team_membership = create(:team_membership, user: owner, team: team, email: owner.email, role: :owner)

        team_membership = UpdateTeamMembership.new.call(team_membership: team_membership, params: {role: :member})

        expect(team_membership.valid?).to be false
      end
    end
  end
end
