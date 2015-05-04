require 'rails_helper'

describe Team do
  describe "validations" do
    it 'Should not allow role to be different from "invitee" if no user is assigned' do
      team_membership = build(:team_membership, roles: [:member], email: 'johndoe@example.com')
      expect(team_membership).not_to be_valid
    end

    it 'Should not allow role to be different from "owner" if team owner and team membership user are the same' do
      owner = create(:user)
      team = create(:team, owner: owner)

      team_membership = build(:team_membership, team: team, user: owner, email: owner.email, roles: [:member])
      expect(team_membership).not_to be_valid
    end
  end
end
