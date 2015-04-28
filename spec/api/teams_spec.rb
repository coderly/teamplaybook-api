require 'rails_helper'

describe "Teams service" do
  describe "POST to create" do

    before do
      create(:plan, slug: "free_plan", name: "Free Plan")
      create(:plan, slug: "pro_plan", name: "Pro Plan")
    end

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

    it "should create a free plan subscription for the team by default" do
      user = create(:user)

      post_json_api '/teams', {data:
        { name: "test team", subdomain: "testteam"}
       }, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      host! "testteam.example.com"

      get "/team", {}, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}
      expect(json.data.plan_name).to eq "Free Plan"
    end

    it "should receive a plan slug and create a subscription for the team to that plan" do
      user = create(:user)

      post_json_api '/teams', {data:
        { name: "test team", subdomain: "testteam", plan: 'pro_plan'}
       }, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      host! "testteam.example.com"

      get "/team", {}, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}
      expect(json.data.plan_name).to eq "Pro Plan"
    end

  end
end