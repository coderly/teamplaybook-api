require 'rails_helper'

describe "team_memberships service" do

  describe "GET /team_memberships" do
    it "should return team memberships for current team if requested from team subdomain" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create_list(:team_membership, 10, team: team)
      create_list(:team_membership, 5, :with_user, team: team)

      host! "test.example.com"

      get "/team_memberships", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.length).to eq 15
    end

    it "should return a 401 Not Authorized if requested without proper tokens" do
      user = create(:user)
      team = create(:team, subdomain: "test")

      host! "test.example.com"

      get "/team_memberships", {}, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(response.code).to eq "401"
      expect(json.error).to eq "Not Authorized"
    end

    it "should return a 403 Forbidden if requested from a non-team subdomain" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create_list(:team_membership, 10, team: team)

      host! "www.example.com"

      get "/team_memberships", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error).to eq "Forbidden"
      expect(response.code).to eq "403"
    end

  end

  describe "POST /team_membership" do
    it "should create a team membership for an unregistered user" do
      owner = create(:user)
      team = create(:team, owner: owner)

      host! "#{team.subdomain}.example.com"

      post_json_api '/team_memberships', {data:
        {email: 'test@example.com'}
       }, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.email).to eq 'test@example.com'
      expect(json.data.links.team.linkage.type).to eq "teams"
      expect(json.data.links.team.linkage.id).to eq team.id.to_s
      expect(json.data.links.user.linkage).to be_nil
    end

    it "should create a team membership for a registered user and asociate the user with the team" do
      owner = create(:user)
      team = create(:team, owner: owner)
      user = create(:user, email: 'test@example.com')

      host! "#{team.subdomain}.example.com"

      post_json_api '/team_memberships', {data:
        {email: 'test@example.com'}
       }, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.email).to eq 'test@example.com'
      expect(json.data.links.team.linkage.type).to eq "teams"
      expect(json.data.links.team.linkage.id).to eq team.id.to_s
      expect(json.data.links.user.linkage.type).to eq "users"
      expect(json.data.links.user.linkage.id).to eq user.id.to_s
    end

    it "should not create a team membership if the user is not the team's owner" do
      user = create(:user)
      team = create(:team)

      host! "#{team.subdomain}.example.com"

      post_json_api '/team_memberships', {data:
        {email: 'test@example.com'}
       }, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(response.code).to eq "401"
      expect(json.error).to eq "Not Authorized"
    end
  end

  describe "POST /team_membership/promote" do
    it "should return a '403 Forbidden' when accessed from non-team subdomain" do
      owner = create(:user)
      team_membership_user = create(:user)
      team = create(:team, owner: owner)
      team_membership = create(:team_membership, team: team, user: team_membership_user, email: team_membership_user.email)

      host! "www.example.com"

      post_json_api "/team_memberships/#{team_membership.id}/promote", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error).to eq "Forbidden"
      expect(response.code).to eq "403"
    end

    it "should return a '401 Not Authorized' if the current user is not the team owner" do
      owner = create(:user)
      some_other_user = create(:user)
      team_membership_user = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_membership_user, email: team_membership_user.email)

      host! "#{team.subdomain}.example.com"

      post_json_api "/team_memberships/#{team_membership.id}/promote", {}, {"X-User-Email" => some_other_user.email, "X-User-Token" => some_other_user.authentication_token}

      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should return a 422 error for team membership with 'invitee' role" do
      owner = create(:user)
      some_other_user = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, email: "unregistered_user@example.com")

      host! "#{team.subdomain}.example.com"

      post_json_api "/team_memberships/#{team_membership.id}/promote", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error.present?).to be true
      expect(response.code).to eq "422"
    end

    it "should promote team membership with 'member' role to 'admin'" do
      owner = create(:user)
      team_membership_user = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_membership_user, email: team_membership_user.email)

      host! "#{team.subdomain}.example.com"

      post_json_api "/team_memberships/#{team_membership.id}/promote", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.roles).to eq ["admin"]
      expect(response.code).to eq "200"
    end

    it "should do nothing for team membership with 'admin' role" do
      owner = create(:user)
      team_membership_user = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_membership_user, email: team_membership_user.email, roles: [:admin])

      host! "#{team.subdomain}.example.com"

      post_json_api "/team_memberships/#{team_membership.id}/promote", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.roles).to eq ["admin"]
      expect(response.code).to eq "200"
    end

    it "should return an error for team membership with 'owner' role" do
      owner = create(:user)
      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: owner, email: owner.email, roles: [:owner])

      host! "#{team.subdomain}.example.com"

      post_json_api "/team_memberships/#{team_membership.id}/promote", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error.present?).to be true
      expect(response.code).to eq "422"
    end
  end

  describe "POST /team_membership/demote" do
    it "should return a '403 Forbidden' when accessed from non-team subdomain" do
      owner = create(:user)
      team_membership_user = create(:user)
      team = create(:team, owner: owner)
      team_membership = create(:team_membership, team: team, user: team_membership_user, email: team_membership_user.email, roles: [:admin])

      host! "www.example.com"

      post_json_api "/team_memberships/#{team_membership.id}/demote", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error).to eq "Forbidden"
      expect(response.code).to eq "403"
    end

    it "should return a '401 Not Authorized' if the current user is not the team owner" do
      owner = create(:user)
      some_other_user = create(:user)
      team_membership_user = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_membership_user, email: team_membership_user.email, roles: [:admin])

      host! "#{team.subdomain}.example.com"

      post_json_api "/team_memberships/#{team_membership.id}/demote", {}, {"X-User-Email" => some_other_user.email, "X-User-Token" => some_other_user.authentication_token}


      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should return a 422 error for team membership with 'invitee' role" do
      owner = create(:user)
      some_other_user = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, email: "unregistered_user@example.com")

      host! "#{team.subdomain}.example.com"

      post_json_api "/team_memberships/#{team_membership.id}/demote", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error.present?).to be true
      expect(response.code).to eq "422"
    end

    it "should do nothing for team membership with 'member' role" do
      owner = create(:user)
      team_membership_user = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_membership_user, email: team_membership_user.email, roles: [:member])

      host! "#{team.subdomain}.example.com"

      post_json_api "/team_memberships/#{team_membership.id}/demote", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.roles).to eq ["member"]
      expect(response.code).to eq "200"
    end

    it "should demote team membership with 'admin' role to 'member'" do
      owner = create(:user)
      team_membership_user = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_membership_user, email: team_membership_user.email, roles: [:admin])

      host! "#{team.subdomain}.example.com"

      post_json_api "/team_memberships/#{team_membership.id}/demote", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.roles).to eq ["member"]
      expect(response.code).to eq "200"
    end

    it "should return an error for team membership with 'owner' role" do
      owner = create(:user)
      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: owner, email: owner.email, roles: [:owner])

      host! "#{team.subdomain}.example.com"

      post_json_api "/team_memberships/#{team_membership.id}/demote", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error.present?).to be true
      expect(response.code).to eq "422"
    end
  end

end
