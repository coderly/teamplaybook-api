require 'rails_helper'

describe "Sign up" do

  describe "Sign up when having an organization_user" do
    it "should add the new user to organization they were added to" do
      organization = create(:organization)
      create(:organization_user, organization: organization, email: 'test@test.com')

      post '/users', data: { email: 'test@test.com', password: 'password', password_confirmation: 'password' }

      user_id = json.data.id

      expect(json.data.email).to eq 'test@test.com'
      expect(User.find(user_id).organizations).to eq [organization]
    end
  end

end