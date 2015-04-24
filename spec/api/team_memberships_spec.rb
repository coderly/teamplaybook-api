require 'rails_helper'

describe "team_memberships service" do

  describe "POST /team_membership" do
    it "should create a team membership for an unregistered user" do
      owner = create(:user)
      team = create(:team, owner: owner)

      host! "#{team.subdomain}.example.com"

      post '/team_memberships', {data:
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

      post '/team_memberships', {data:
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

      post '/team_memberships', {data:
        {email: 'test@example.com'}
       }, {"X-User-Email" => user.email, "X-User-Token" => user.authentication_token}

      expect(response.code).to eq "401"
      expect(json.error).to eq "Not Authorized"
    end
  end

end