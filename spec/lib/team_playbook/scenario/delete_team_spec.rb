require 'rails_helper'
require 'team_playbook/scenario/delete_team'

module TeamPlaybook
  module Scenario
    describe DeleteTeam do
      it "should soft delete team" do
        team = create(:team)

        DeleteTeam.new.call(team: team)
        expect(team.deleted?).to be true
        expect(Team.count).to be 0
        expect(Team.with_deleted.count).to be 1
      end
    end
  end
end
