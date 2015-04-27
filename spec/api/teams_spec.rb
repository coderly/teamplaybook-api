require 'rails_helper'

describe "Teams service" do
  describe "POST to create" do

    it "should create an team for a user" do
      user = create(:user)

      post_json_api '/teams', {data:
        { name: "test team", subdomain: "testteam"}
       }, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(json.data.name).to eq "test team"
      expect(json.data.subdomain).to eq "testteam"
      expect(json.data.links.owner.linkage.type).to eq "users"
      expect(json.data.links.owner.linkage.id).to eq user.id.to_s
    end

    it "should save the team and return the team when using its subdomain" do
      user = create(:user)

      post_json_api '/teams', {data:
        { name: "test team", subdomain: "testteam"}
       }, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      host! "testteam.example.com"

      get "/team", {}, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}
      expect(json.data.name).to eq "test team"
      expect(json.data.subdomain).to eq "testteam"
      expect(json.data.links.owner.linkage.type).to eq "users"
      expect(json.data.links.owner.linkage.id).to eq user.id.to_s
    end

  end
end