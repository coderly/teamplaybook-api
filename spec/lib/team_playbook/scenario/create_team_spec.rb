require 'rails_helper'
require 'team_playbook/scenario/create_team'

module TeamPlaybook
  module Scenario
    describe CreateTeam do

      before do
        create(:plan, slug: "free_plan", name: "Free Plan", amount: 0)
      end

      it "should create a team" do
        owner = create(:user, email: "owner@example.com")
        team = CreateTeam.new.call(team_params: {subdomain: "test", name: "Test"}, owner: owner)

        expect(team.persisted?).to be true
      end

      it "should create a team membership with 'owner' role assinged to team owner" do
        owner = create(:user, email: "owner@example.com")
        team = CreateTeam.new.call(team_params: {subdomain: "test", name: "Test"}, owner: owner)

        team_membership = TeamMembership.where(user: owner, team: team).first

        expect(team_membership.has_role? :owner).to be true
      end

      it "should subscribe created team to default plan" do
        owner = create(:user, email: "owner@example.com")
        team = CreateTeam.new.call(team_params: {subdomain: "test", name: "Test"}, owner: owner)

        expect(team.plan.name).to eq "Free Plan"
      end
    end
  end
end
