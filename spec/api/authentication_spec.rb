require 'rails_helper'

describe "Authentication" do

  describe "POST /tokens" do
    it "should log in a user" do
      user = create(:user, email: 'test@test.com', password: 'password', password_confirmation: 'password', authentication_token: 'xcccsswwee')

      post '/accounts/tokens', user: { email: 'test@test.com', password: 'password' }

      expect(json.data.authentication_token).to eq 'xcccsswwee'
      expect(json.data.email).to eq 'test@test.com'
      expect(json.data.role.present?).to be false
    end

    it "should return the current team membership if authenticated from a team domain" do
      user = create(:user, email: 'test@test.com', password: 'password', password_confirmation: 'password', authentication_token: 'xcccsswwee')
      team = create(:team, owner: user)

      create(:team_membership, user: user, team: team, role: owner)
      host! "#{team.subdomain}.example.com"

      post '/accounts/tokens', user: { email: 'test@test.com', password: 'password' }
      expect(json.data.role).to eq "owner"
    end
  end

  describe "register" do
    it "should create user" do
      post_json_api '/accounts', data: { email: 'test@test.com', password: 'password', password_confirmation: 'password' }

      expect(json.data.authentication_token).not_to be_nil
      expect(json.data.email).to eq 'test@test.com'
    end

    it "should authenticate with resulting token" do
      post_json_api '/accounts', data: { email: 'test@test.com', password: 'password', password_confirmation: 'password' }
      get '/me', {}, {"X-User-Email" => json.data.email, "X-User-Token" => json.data.authentication_token}

      expect(json.data.email).to eq 'test@test.com'
    end

    it "should return an errors in the correct format" do
       post_json_api '/accounts', data: { email: 'test@test.com', password: 'pas', password_confirmation: 'pas' }
       expect(json.error).to eq "Password is too short (minimum is 8 characters)"
    end
  end
end
