require 'rails_helper'

describe "Organizations service" do
  describe "POST to create" do

    it "should create an organization for a user" do
      user = create(:user)

      post_json_api '/organizations', {data:
        { name: "test organization", subdomain: "testorganization"}
       }, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(json.data.name).to eq "test organization"
      expect(json.data.subdomain).to eq "testorganization"
      expect(json.data.links.user.linkage.type).to eq "users"
      expect(json.data.links.user.linkage.id).to eq user.id.to_s
    end

    it "should save the organization and return the organization when using its subdomain" do
      user = create(:user)

      post_json_api '/organizations', {data:
        { name: "test organization", subdomain: "testorganization"}
       }, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      host! "testorganization.example.com"

      get "/organization", {}, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}
      expect(json.data.name).to eq "test organization"
      expect(json.data.subdomain).to eq "testorganization"
      expect(json.data.links.user.linkage.type).to eq "users"
      expect(json.data.links.user.linkage.id).to eq user.id.to_s
    end

  end
end