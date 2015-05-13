require 'rails_helper'

describe Team do
  describe "validations" do
    it 'Should not allow role to be different from "invitee" if no user is assigned' do
      team_membership = build(:team_membership, role: :member, email: 'johndoe@example.com')
      expect(team_membership).not_to be_valid
    end

    it 'Should not allow role to be different from "owner" if team owner and team membership user are the same' do
      owner = create(:user)
      team = create(:team, owner: owner)

      team_membership = build(:team_membership, team: team, user: owner, email: owner.email, role: :member)
      expect(team_membership).not_to be_valid
    end
  end

  describe "#role" do
    it 'Should set roles to a single-element array when setting the role property' do
      team_membership = build(:team_membership)
      team_membership.role = :owner

      expect(team_membership.roles.to_a).to eq [:owner]
    end

    it 'Should retrieve the first role in the role array when retrieving the role property' do
      team_membership = build(:team_membership, role: :admin)

      expect(team_membership.role).to eq :admin
    end
  end
end
