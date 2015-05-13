require 'rails_helper'

describe 'team members service' do
  describe 'GET /users' do
    it "should retrieve only team members if the request is from a team subdomain" do
      owner = create(:user)
      team_a = create(:team, :with_users, subdomain: "team-a", number_of_users: 10, owner: owner)
      create(:team_membership, user: owner, team: team_a, role: :owner)
      team_b = create(:team, :with_users, subdomain: "team-b", number_of_users: 5, owner: owner)
      create(:team_membership, user: owner, team: team_b, role: :owner)


      host! "team-a.example.com"

      get "/users", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.count).to eq(11)

      host! "team-b.example.com"

      get "/users", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.count).to eq(6)
    end

    it "should return a 401 Not Authorized if requested by a user who isn't a team member" do
      user = create(:user)
      team = create(:team, subdomain: "test")

      host! "test.example.com"

      get "/users", {}, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(response.code).to eq "401"
      expect(json.error).to eq "Not Authorized"
    end

    it "should return a 403 Forbidden if requested from a non-team subdomain" do
      owner = create(:user)
      team = create(:team, :with_users, number_of_users: 10, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      host! "www.example.com"

      get "/users", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.error).to eq "Forbidden"
      expect(response.code).to eq "403"
    end
  end
end