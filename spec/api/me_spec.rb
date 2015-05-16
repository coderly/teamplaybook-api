require 'rails_helper'

describe "me" do

  describe "GET /me" do
    it "retrieve the current user without role or membership when called from non-team subdomain" do
      user = create(:user, email: 'test@test.com', password: 'password', password_confirmation: 'password', authentication_token: 'xcccsswwee')

      get '/me', {}, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(json.data.authentication_token).to eq 'xcccsswwee'
      expect(json.data.email).to eq 'test@test.com'
      expect(json.data.role.present?).to be false
    end

    it "retrieve the current user with role and membership when called from team subdomain" do
      user = create(:user, email: 'test@test.com', password: 'password', password_confirmation: 'password', authentication_token: 'xcccsswwee')
      team = create(:team, name: "Test", subdomain: "test", owner: user)
      team_membership = create(:team_membership, team: team, user: user, role: :owner)

      host! "test.example.com"

      get '/me', {}, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(json.data.authentication_token).to eq 'xcccsswwee'
      expect(json.data.email).to eq 'test@test.com'
      expect(json.data.role.present?).to be true
      expect(json.data.links.current_team_membership.linkage.id).to eq team_membership.id.to_s
    end
  end
end