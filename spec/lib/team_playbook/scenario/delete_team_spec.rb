require 'rails_helper'
require 'team_playbook/scenario/archive_team'

module TeamPlaybook
  module Scenario
    describe ArchiveTeam do
      it "should archive team" do
        team = create(:team)

        ArchiveTeam.new.call(team: team)
        expect(team.archived?).to be true
        expect(Team.active.count).to be 0
      end
    end
  end
end
