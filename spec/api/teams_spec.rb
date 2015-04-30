require 'rails_helper'

describe "Teams service" do
  describe "POST to create" do

    before do
      create(:plan, slug: "free_plan", name: "Free Plan", amount: 0)
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

  end

  describe "Post to change_plan" do
    before do
      create(:plan, slug: "free_plan", name: "Free Plan", amount: 0)
      create(:plan, slug: "pro_plan", name: "Pro Plan")
    end

    it "Should change a team's plan" do
      user = create(:user)
      card_token = valid_stripe_card_token

      post_json_api '/teams', {data:
        { name: "test team", subdomain: "testteam"}
       }, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      host! "testteam.example.com"

      post_json_api '/team/change_plan', {plan_slug: 'pro_plan', card_token: card_token},
       {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      get "/team", {}, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}
      expect(json.data.plan_name).to eq "Pro Plan"
    end
  end
end