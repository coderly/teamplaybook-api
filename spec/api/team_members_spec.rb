require 'rails_helper'

describe 'team members service' do
  describe 'GET /users' do
    it "should retrieve all users if the request is from a non-team subdomain" do

      create(:team, :with_users, number_of_users: 10)
      create(:team, :with_users, number_of_users: 5)

      get "/users"

      expect(json.data.count).to eq(15)
    end

    it "should retrieve only team members if the request is from a team subdomain" do

      team_a = create(:team, :with_users, subdomain: "team-a", number_of_users: 10)
      team_b = create(:team, :with_users, subdomain: "team-b", number_of_users: 5)

      host! "team-a.example.com"

      get "/users"

      expect(json.data.count).to eq(10)

      host! "team-b.example.com"

      get "/users"

      expect(json.data.count).to eq(5)
    end
  end
end