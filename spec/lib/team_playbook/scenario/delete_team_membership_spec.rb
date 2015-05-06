require 'rails_helper'
require 'team_playbook/scenario/update_team_membership'

module TeamPlaybook
  module Scenario
    describe UpdateTeamMembership do
      it "should not delete an 'owner'" do
        user = create(:user)
        team = create(:team, owner: user)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, roles: [:owner])

        success = DeleteTeamMembership.new.call(team_membership: team_membership)

        expect(success).to eq false
      end

      it "should delete an 'invitee'" do
        team = create(:team)

        team_membership = create(:team_membership, team: team, email: "invite@example.com", roles: [:invitee])

        success = DeleteTeamMembership.new.call(team_membership: team_membership)

        expect(success).to eq true
      end

      it "should delete a 'member'" do
        user = create(:user)
        team = create(:team)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, roles: [:member])

        success = DeleteTeamMembership.new.call(team_membership: team_membership)

        expect(success).to eq true
      end

      it "should delete an 'admin'" do
        user = create(:user)
        team = create(:team)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, roles: [:admin])

        success = DeleteTeamMembership.new.call(team_membership: team_membership)

        expect(success).to eq true
      end
    end
  end
end
