require 'rails_helper'
require 'team_playbook/scenario/create_team_membership'

module TeamPlaybook
  module Scenario
    describe CreateTeamMembership do
      it 'should create a team membership with "invitee" role when there is no user with specified e-mail' do
        team = create(:team)
        team_membership = CreateTeamMembership.new.call(team, email: 'johndoe@example.com')

        expect(team_membership.invitee?).to be true
      end

      it "should create a team membership with 'member' role when there is a user with specified e-mail" do
        user = create(:user, email: "johndoe@example.com")
        team = create(:team)

        team_membership = CreateTeamMembership.new.call(team, email: "johndoe@example.com")

        expect(team_membership.member?).to be true
      end

      it "should create a team membership with 'owner' role when the user with the specified e-mail is the team owner" do
        owner = create(:user, email: "owner@example.com")
        team = create(:team, owner: owner)

        team_membership = CreateTeamMembership.new.call(team, email: owner.email)

        expect(team_membership.owner?).to be true
      end
    end
  end
end
