require 'rails_helper'
require 'team_playbook/scenario/delete_team'

module TeamPlaybook
  module Scenario
    describe DeleteTeam do
      it "should delete team" do
        team = create(:team)

        expect{DeleteTeam.new.call(team: team)}.not_to raise_error
        expect(Team.all.count).to be 0
      end

      it "should delete associated memberships" do
        user = create(:user)
        team = create(:team)
        other_team = create(:team)
        create_list(:team_membership, 10, team: team)
        create_list(:team_membership, 5, team: other_team)

        expect{DeleteTeam.new.call(team: team)}.not_to raise_error
        expect(TeamMembership.all.count).to eq 5
      end
    end
  end
end
