require 'rails_helper'

describe "organization_users service" do

  describe "POST /organization_user" do
    it "should create an organization_user for an unregistered user" do
      owner = create(:user)
      organization = create(:organization, owner: owner)

      host! "#{organization.subdomain}.example.com"

      post '/organization_users', {data:
        {email: 'test@example.com'}
       }, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.email).to eq 'test@example.com'
      expect(json.data.links.organization.linkage.type).to eq "organizations"
      expect(json.data.links.organization.linkage.id).to eq organization.id.to_s
      expect(json.data.links.user.linkage).to be_nil
    end

    it "should create an organization_user for a registered user and asociate the user with the organization" do
      owner = create(:user)
      organization = create(:organization, owner: owner)
      user = create(:user, email: 'test@example.com')

      host! "#{organization.subdomain}.example.com"

      post '/organization_users', {data:
        {email: 'test@example.com'}
       }, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.email).to eq 'test@example.com'
      expect(json.data.links.organization.linkage.type).to eq "organizations"
      expect(json.data.links.organization.linkage.id).to eq organization.id.to_s
      expect(json.data.links.user.linkage.type).to eq "users"
      expect(json.data.links.user.linkage.id).to eq user.id.to_s
    end

    it "should not create an organization_user if the user is not the organization's owner" do
      user = create(:user)
      organization = create(:organization)

      host! "#{organization.subdomain}.example.com"

      post '/organization_users', {data:
        {email: 'test@example.com'}
       }, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(response.code).to eq "401"
      expect(json.error).to eq "Not Authorized"
    end
  end

end