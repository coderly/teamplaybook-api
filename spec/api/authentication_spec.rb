require 'rails_helper'

describe "Authentication" do
  
  it "should log in a user" do
    user = create(:user, email: 'test@test.com', password: 'password', password_confirmation: 'password', auth_token: 'xcccsswwee')

    expect(ReissuedPlugins).to receive(:user_signed_in).with(user)

    post '/users/sign_in.json', user: { email: 'test@test.com', password: 'password' }
  
    expect(json.user_token).to eq 'xcccsswwee'
    expect(json.user_email).to eq 'test@test.com'
  end

end