require 'rails_helper'

describe "Sign up" do
  describe "when having a team_membership" do
    it "should add the new user to team they were added to" do
      team = create(:team)
      create(:team_membership, team: team, email: 'test@test.com', role: :invitee)

      post_json_api '/accounts', data: { email: 'test@test.com', password: 'password', password_confirmation: 'password' }

      user_id = json.data.id

      expect(json.data.email).to eq 'test@test.com'
      expect(User.find(user_id).teams).to eq [team]
    end
  end
end