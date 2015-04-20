require 'rails_helper'

describe "Authentication" do
  
  it "should log in a user" do
    user = create(:user, email: 'test@test.com', password: 'password', password_confirmation: 'password', auth_token: 'xcccsswwee')

    expect(ReissuedPlugins).to receive(:user_signed_in).with(user)

    post '/users/sign_in', user: { email: 'test@test.com', password: 'password' }
  
    expect(json.user_token).to eq 'xcccsswwee'
    expect(json.user_email).to eq 'test@test.com'
  end

  it "should authenticate with resulting token" do
    post '/users', user: { email: 'test@test.com', password: 'password', password_confirmation: 'password' }

    post '/users/sign_in', user: { email: 'test@test.com', password: 'password' }

    token_authorize(json.user_token, json.user_email)
    get 'me'
  
    expect(json.user.email).to eq 'test@test.com'
  end

  describe "register" do
    it "should create user" do
      post '/users', user: { email: 'test@test.com', password: 'password', password_confirmation: 'password' }
  
      expect(json.user_email).to eq 'test@test.com'
      expect(json.user_token).not_to be_nil
    end

    it "should authenticate with resulting token" do
      post '/users', user: { email: 'test@test.com', password: 'password', password_confirmation: 'password' }

      token_authorize(json.user_token, json.user_email)
      get 'api/v1/me'
  
      expect(json.user.registered).to be true
      expect(json.user.email).to eq 'test@test.com'
    end

    it "should return an errors in the correct format" do
       post '/users', user: { email: 'test@test.com', password: 'pas', password_confirmation: 'pas' }
       expect(json.error).to eq "Email has already been taken and Password is too short (minimum is 8 characters)"
    end
  end
end