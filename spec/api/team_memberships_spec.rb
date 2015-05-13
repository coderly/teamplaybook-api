require 'rails_helper'

describe "team_memberships service" do

  describe "GET /team-memberships" do
    it "should return team memberships for current team if requested from team subdomain" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create(:team_membership, team: team, user: owner, role: :owner)
      create_list(:team_membership, 10, team: team)
      create_list(:team_membership, 5, :with_user, team: team)

      host! "test.example.com"

      get "/team-memberships", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.length).to eq 16
    end

    it "should return a 401 Not Authorized if requested without proper tokens" do
      user = create(:user)
      team = create(:team, subdomain: "test")

      host! "test.example.com"

      get "/team-memberships", {}, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(response.code).to eq "401"
      expect(json.error).to eq "Not Authorized"
    end

    it "should return a 403 Forbidden if requested from a non-team subdomain" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create_list(:team_membership, 10, team: team)

      host! "www.example.com"

      get "/team-memberships", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error).to eq "Forbidden"
      expect(response.code).to eq "403"
    end
  end

  describe "POST /team-memberships" do
    it "should create a team membership for an unregistered user" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, team: team, user: owner, role: :owner)

      host! "#{team.subdomain}.example.com"

      post_json_api '/team-memberships', {data:
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
      create(:team_membership, user: owner, team: team, role: :owner)

      host! "#{team.subdomain}.example.com"

      post_json_api '/team-memberships', {data:
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

      post_json_api '/team-memberships', {data:
        {email: 'test@example.com'}
       }, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(response.code).to eq "401"
      expect(json.error).to eq "Not Authorized"
    end
  end

  describe "GET /team-memberships/:id" do
    it "should return the specified team membership if requested from team subdomain by a team user" do
      owner = create(:user)
      team_member = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create(:team_membership, team: team, user: owner, roles: [:owner])
      team_membership = create(:team_membership, team: team, user: team_member, roles: [:member])

      host! "test.example.com"

      get "/team-memberships/#{team_membership.id}", {}, {"X-User-Email" => team_member.email, "X-User-Token" => team_member.authentication_token}

      expect(response.code).to eq "200"
      expect(json.data.id).to eq team_membership.id.to_s
    end

    it "should return a 401 Not Authorized if requested from team subdomain by a non-team user" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      team_membership = create(:team_membership, team: team, user: owner, roles: [:owner])

      non_team_member = create(:user)

      host! "test.example.com"

      get "/team-memberships/#{team_membership.id}", {}, {"X-User-Email" => non_team_member.email, "X-User-Token" => non_team_member.authentication_token}

      expect(response.code).to eq "401"
      expect(json.error).to eq "Not Authorized"
    end

    it "should return a 401 Not Authorized if requested from a team subdomain by an anonymous user" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      team_membership = create(:team_membership, team: team, user: owner, roles: [:owner])

      host! "test.example.com"

      get "/team-memberships/#{team_membership.id}", {}

      expect(response.code).to eq "401"
      expect(json.error).to eq "Not Authorized"
    end

    it "should return a 403 Forbidden if requested from a non-team subdomain" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      team_membership = create(:team_membership, team: team, user: owner, roles: [:owner])

      host! "www.example.com"

      get "/team-memberships/#{team_membership.id}", {}

      expect(response.code).to eq "403"
      expect(json.error).to eq "Forbidden"
    end
  end

  describe "PATCH /team-memberships/:id" do
    it "should return a '403 Forbidden' when accessed from non-team subdomain" do
      owner = create(:user)
      team_membership_user = create(:user)
      team = create(:team, owner: owner)
      team_membership = create(:team_membership, team: team, user: team_membership_user, email: team_membership_user.email)

      host! "www.example.com"

      patch_json_api "/team-memberships/#{team_membership.id}", {data: {role: :admin}}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error).to eq "Forbidden"
      expect(response.code).to eq "403"
    end

    it "should require authorization" do
      owner = create(:user)
      team_member = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email)

      host! "#{team.subdomain}.example.com"

      patch_json_api "/team-memberships/#{team_membership.id}", {data: {role: :admin}}

      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should not authorize for a request from a user who is not a member of the team" do
      owner = create(:user)
      some_other_user = create(:user)
      team_member = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email, role: :member)

      host! "#{team.subdomain}.example.com"

      patch_json_api "/team-memberships/#{team_membership.id}", {data: {role: :admin}}, {
        "X-User-Email" => some_other_user.email, "X-User-Token" => some_other_user.authentication_token
      }

      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should not authorize for a request from a regular member" do
      owner = create(:user)
      team_member = create(:user)
      some_other_team_member = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email, role: :member)
      create(:team_membership, team: team, user: some_other_team_member, email: some_other_team_member.email, role: :member)

      host! "#{team.subdomain}.example.com"

      patch_json_api "/team-memberships/#{team_membership.id}", {data: {role: :admin}}, {
        "X-User-Email" => some_other_team_member.email, "X-User-Token" => some_other_team_member.authentication_token
      }

      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should authorize for a request from an admin" do
      owner = create(:user)
      team_member = create(:user)
      some_other_team_member = create(:user)
      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email, role: :member)
      create(:team_membership, team: team, user: some_other_team_member, email: some_other_team_member.email, role: :admin)

      host! "#{team.subdomain}.example.com"

      patch_json_api "/team-memberships/#{team_membership.id}", {data: {role: :admin}}, {
        "X-User-Email" => some_other_team_member.email, "X-User-Token" => some_other_team_member.authentication_token
      }

      expect(response.code).to eq "200"
    end

    it "should authorize for a request from the team owner" do
      owner = create(:user)
      team_member = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, team: team, user: owner, role: :owner)

      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email, role: :member)

      host! "#{team.subdomain}.example.com"

      patch_json_api "/team-memberships/#{team_membership.id}", {data: {role: :admin}}, {
        "X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token
      }

      expect(response.code).to eq "200"
    end

    it "should return a 422 error when updating membership with 'invitee' role" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      team_member = create(:user)
      team_membership = create(:team_membership, team: team, email: "unregistered_user@example.com")

      host! "#{team.subdomain}.example.com"

      patch_json_api "/team-memberships/#{team_membership.id}", {data: {role: :admin}}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error.present?).to be true
      expect(response.code).to eq "422"
    end

    it "should return a 422 error when updating membership with 'owner' role" do
      owner = create(:user)
      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: owner, email: owner.email, role: :owner)

      host! "#{team.subdomain}.example.com"

      patch_json_api "/team-memberships/#{team_membership.id}", {data: {role: :admin}}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error.present?).to be true
      expect(response.code).to eq "422"
    end

    it "should allow changing of membership with 'member' role to 'admin'" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      team_membership_user = create(:user)
      team_membership = create(:team_membership, team: team, user: team_membership_user, email: team_membership_user.email)

      host! "#{team.subdomain}.example.com"

      patch_json_api "/team-memberships/#{team_membership.id}", {data: {role: :admin}}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.role).to eq "admin"
      expect(response.code).to eq "200"
    end


    it "should allow changing of membership with 'admin' role to 'member'" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      team_membership_user = create(:user)
      team_membership = create(:team_membership, team: team, user: team_membership_user, email: team_membership_user.email, role: :admin)

      host! "#{team.subdomain}.example.com"

      patch_json_api "/team-memberships/#{team_membership.id}", {data: {role: :member}}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.role).to eq "member"
      expect(response.code).to eq "200"
    end
  end

  describe "DELETE /team-memberships/:id" do
    it "should return a '403 Forbidden' when accessed from non-team subdomain" do
      owner = create(:user)
      team_member = create(:user)
      team = create(:team, owner: owner)
      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email)

      host! "www.example.com"

      delete "/team-memberships/#{team_membership.id}", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error).to eq "Forbidden"
      expect(response.code).to eq "403"
    end

    it "should require authorization" do
      owner = create(:user)
      team_member = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email)

      host! "#{team.subdomain}.example.com"

      delete "/team-memberships/#{team_membership.id}"

      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should not authorize for a request from a user who is not a member of the team" do
      owner = create(:user)
      some_other_user = create(:user)
      team_member = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email, role: :member)

      host! "#{team.subdomain}.example.com"

      delete "/team-memberships/#{team_membership.id}", {}, {
        "X-User-Email" => some_other_user.email, "X-User-Token" => some_other_user.authentication_token
      }

      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should not authorize for a request from a regular member if it's for deleting someone else's membership" do
      owner = create(:user)
      team_member = create(:user)
      some_other_team_member = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email, role: :member)
      create(:team_membership, team: team, user: some_other_team_member, email: some_other_team_member.email, role: :member)

      host! "#{team.subdomain}.example.com"

      delete "/team-memberships/#{team_membership.id}", {}, {
        "X-User-Email" => some_other_team_member.email, "X-User-Token" => some_other_team_member.authentication_token
      }

      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should not authorize for a request from an admin if it's for deleting someone else's membership" do
      owner = create(:user)
      team_member = create(:user)
      some_other_team_member = create(:user)

      team = create(:team, owner: owner)

      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email, role: :member)
      create(:team_membership, team: team, user: some_other_team_member, email: some_other_team_member.email, role: :admin)

      host! "#{team.subdomain}.example.com"

      delete "/team-memberships/#{team_membership.id}", {}, {
        "X-User-Email" => some_other_team_member.email, "X-User-Token" => some_other_team_member.authentication_token
      }

      expect(json.error).to eq "Not Authorized"
      expect(response.code).to eq "401"
    end

    it "should authorize for a request from the team owner" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      team_member = create(:user)
      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email, role: :member)

      host! "#{team.subdomain}.example.com"

      delete "/team-memberships/#{team_membership.id}", {}, {
        "X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token
      }

      expect(response.code).to eq "204"
    end

    it "should not allow deletion of owner role" do
      owner = create(:user)
      team = create(:team, owner: owner)
      team_membership = create(:team_membership, team: team, user: owner, email: owner.email, role: :owner)

      host! "#{team.subdomain}.example.com"

      delete "/team-memberships/#{team_membership.id}", {}, {
        "X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token
      }

      expect(json.error.present?).to be true
      expect(response.code).to eq "405"
    end

    it "should allow a member to remove themselves from the team" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, team: team, user: owner, email: owner.email, roles: [:owner])


      team_member = create(:user)
      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email, roles: [:member])

      host! "#{team.subdomain}.example.com"

      delete "/team-memberships/#{team_membership.id}", {}, {
        "X-User-Email" => team_member.email, "X-User-Token" => team_member.authentication_token
      }

      expect(response.code).to eq "204"
    end

    it "should allow an admin to remove themselves from the team" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, team: team, user: owner, email: owner.email, roles: [:owner])


      team_member = create(:user)
      team_membership = create(:team_membership, team: team, user: team_member, email: team_member.email, roles: [:admin])

      host! "#{team.subdomain}.example.com"

      delete "/team-memberships/#{team_membership.id}", {}, {
        "X-User-Email" => team_member.email, "X-User-Token" => team_member.authentication_token
      }

      expect(response.code).to eq "204"
    end
  end

end
