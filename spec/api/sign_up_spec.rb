require 'rails_helper'

describe "Sign up" do

  describe "Sign up when having an invitation" do
    it "should add the new user to organization they were invited to" do
      organization = create(:organization)
      invitation = create(:invitation, organization: organization, email: 'test@test.com')

      post '/users', data: { email: 'test@test.com', password: 'password', password_confirmation: 'password' }

      user_id = json.data.id

      expect(json.data.email).to eq 'test@test.com'
      expect(User.find(user_id).organizations).to eq [organization]
    end
  end

end