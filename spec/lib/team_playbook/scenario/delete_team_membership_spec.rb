require 'rails_helper'
require 'team_playbook/scenario/update_team_membership'
require 'errors/cannot_destroy_team_owner_membership_error'

module TeamPlaybook
  module Scenario
    describe UpdateTeamMembership do
      it "should not delete an 'owner'" do
        user = create(:user)
        team = create(:team, owner: user)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, roles: [:owner])

        expect{DeleteTeamMembership.new.call(team_membership: team_membership)}.to raise_error CannotDestroyTeamOwnerMembership
      end

      it "should delete an 'invitee'" do
        team = create(:team)

        team_membership = create(:team_membership, team: team, email: "invite@example.com", roles: [:invitee])

        expect{DeleteTeamMembership.new.call(team_membership: team_membership)}.not_to raise_error
      end

      it "should delete a 'member'" do
        user = create(:user)
        team = create(:team)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, roles: [:member])

        expect{DeleteTeamMembership.new.call(team_membership: team_membership)}.not_to raise_error
      end

      it "should delete an 'admin'" do
        user = create(:user)
        team = create(:team)

        team_membership = create(:team_membership, user: user, team: team, email: user.email, roles: [:admin])

        expect{DeleteTeamMembership.new.call(team_membership: team_membership)}.not_to raise_error
      end
    end
  end
end
