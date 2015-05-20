require 'rails_helper'

describe "Teams service" do
  describe "GET /team" do
    it "should return a 403 Forbidden when called from non-team subdomain" do
      user = create(:user)
      team = create(:team)

      host! "www.example.com"

      get "/team", {}, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(response.code).to eq "403"
    end

    it "should return a 401 Not Authorized when called from a team subdomain by an unauthenticated user" do
      team = create(:team)

      host! "#{team.subdomain}.example.com"

      get "/team"

      expect(response.code).to eq "401"
    end

    it "should return a 401 Not Authorized when called from a team subdomain by an authenticated non-member of the team" do
      user = create(:user)
      team = create(:team)

      host! "#{team.subdomain}.example.com"

      get "/team", {}, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(response.code).to eq "401"
    end

    it "should fetch the team when called from a team subdomain by an authenticated team member" do
      member = create(:user)
      team = create(:team)
      team_membership = create(:team_membership, user: member, team: team, role: :member)

      host! "#{team.subdomain}.example.com"

      get "/team", {}, {"X-User-Email" => member.email, "X-User-Token" => member.authentication_token}

      expect(response.code).to eq "200"
      expect(json.data.subdomain).to eq team.subdomain
      expect(json.data.name).to eq team.name
    end
  end

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

    it "should require a card token if the plan is a paid plan" do
      plan = create(:plan, slug: "Expensive Plan", amount: 3000)
      user = create(:user)
      card_token = valid_stripe_card_token

      post_json_api '/teams', {data:
        { name: "test team", subdomain: "testteam"}
       }, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      host! "testteam.example.com"

      post_json_api '/team/change_plan', {plan_slug: plan.slug},
       {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(response.code).to eq "422"
      expect(json.error).to eq "A credit card is required for a paid plan."
    end
  end

  describe "DELETE /teams/:id" do
    it "should return a '403 Forbidden' when accessed from non-team subdomain" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      host! "www.example.com"

      delete "/teams/#{team.id}", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error).to eq "Forbidden"
      expect(response.code).to eq "403"
    end

    it "should require authorization" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      host! "#{team.subdomain}.example.com"

      delete "/teams/#{team.id}"

      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should not authorize for a request from a user who is not a member of the team" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      some_other_user = create(:user)

      host! "#{team.subdomain}.example.com"

      delete "/teams/#{team.id}", {}, {
        "X-User-Email" => some_other_user.email, "X-User-Token" => some_other_user.authentication_token
      }

      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should not authorize for a request from a user with 'member' role" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      team_member = create(:user)
      create(:team_membership, user: team_member, team: team, role: :member)

      host! "#{team.subdomain}.example.com"

      delete "/teams/#{team.id}", {}, {
        "X-User-Email" => team_member.email, "X-User-Token" => team_member.authentication_token
      }

      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should not authorize for a request from a user with 'admin' role" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      team_admin = create(:user)
      create(:team_membership, user: team_admin, team: team, role: :admin)

      host! "#{team.subdomain}.example.com"

      delete "/teams/#{team.id}", {}, {
        "X-User-Email" => team_admin.email, "X-User-Token" => team_admin.authentication_token
      }

      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should allow deletion by team owner" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      host! "#{team.subdomain}.example.com"

      delete "/teams/#{team.id}", {}, {
        "X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token
      }

      expect(response.code).to eq "204"

      get "/team", {}, {
        "X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token
      }

      expect(response.code).to eq "404"
    end
  end
end
