require 'rails_helper'
require 'team_playbook/scenario/delete_team_membership'
require 'errors/cannot_remove_owner_from_team_error'

module TeamPlaybook
  module Scenario
    describe DeleteTeamMembership do
      it "should not delete an 'owner'" do
        user = create(:user)
        team = create(:team, owner: user)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, role: :owner)

        expect{DeleteTeamMembership.new.call(team_membership: team_membership)}.to raise_error CannotRemoveOwnerFromTeam
      end

      it "should delete an 'invitee'" do
        team = create(:team)

        team_membership = create(:team_membership, team: team, email: "invite@example.com", role: :invitee)
        DeleteTeamMembership.new.call(team_membership: team_membership)
        expect(team_membership).not_to be_persisted
      end

      it "should delete a 'member'" do
        user = create(:user)
        team = create(:team)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, role: :member)
        DeleteTeamMembership.new.call(team_membership: team_membership)
        expect(team_membership).not_to be_persisted
      end

      it "should delete an 'admin'" do
        user = create(:user)
        team = create(:team)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, role: :admin)
        DeleteTeamMembership.new.call(team_membership: team_membership)
        expect(team_membership).not_to be_persisted
      end
    end
  end
end
