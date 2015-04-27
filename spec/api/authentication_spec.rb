require 'rails_helper'

describe "Authentication" do

  describe "POST /tokens" do
    it "should log in a user" do
      user = create(:user, email: 'test@test.com', password: 'password', password_confirmation: 'password', authentication_token: 'xcccsswwee')

      post '/users/tokens', user: { email: 'test@test.com', password: 'password' }

      expect(json.data.authentication_token).to eq 'xcccsswwee'
      expect(json.data.email).to eq 'test@test.com'
    end

    it "should authenticate with resulting token" do
      user = create(:user, email: 'test@test.com', password: 'password', password_confirmation: 'password', authentication_token: 'xcccsswwee')

      post '/users/tokens', user: { email: 'test@test.com', password: 'password' }

      get '/me', {}, {"X-User-Email" => json.data.email, "X-User-Token" => json.data.authentication_token}

      expect(json.data.email).to eq 'test@test.com'
    end
  end

  describe "register" do
    it "should create user" do
      post_json_api '/users', data: { email: 'test@test.com', password: 'password', password_confirmation: 'password' }

      expect(json.data.authentication_token).not_to be_nil
      expect(json.data.email).to eq 'test@test.com'
    end

    it "should authenticate with resulting token" do
      post_json_api '/users', data: { email: 'test@test.com', password: 'password', password_confirmation: 'password' }
      get '/me', {}, {"X-User-Email" => json.data.email, "X-User-Token" => json.data.authentication_token}

      expect(json.data.email).to eq 'test@test.com'
    end

    it "should return an errors in the correct format" do
       post_json_api '/users', data: { email: 'test@test.com', password: 'pas', password_confirmation: 'pas' }
       expect(json.error).to eq "Password is too short (minimum is 8 characters)"
    end
  end
end