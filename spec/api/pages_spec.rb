require 'rails_helper'

describe 'Pages service' do
  describe 'GET /pages' do
    it "should return all pages" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create(:team_membership, team: team, user: owner, role: :owner)

      create(:page, title: "Test page", root: true, team: team)
      create(:page, title: "Test page 2", root: true, team: team)

      host! "test.example.com"

      get "/pages", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}
      expect(json.data.size).to eq 2
      expect(json.data.map(&:title)).to match_array ["Test page", "Test page 2"]
    end

    it "should return the pages with the children ids" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create(:team_membership, team: team, user: owner, role: :owner)

      root_page = create(:page, title: "Root Test page", root: true, team: team)
      child_page = create(:page, title: "Child page 1", root: true, team: team, parent: root_page)
      child_page2 = create(:page, title: "Child page 2", root: true, team: team, parent: root_page)

      host! "test.example.com"

      get "/pages", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}
      expect(json.data.size).to eq 3
      expect(json.data.first.links.children.linkage.map(&:id)).to match_array [child_page.id.to_s, child_page2.id.to_s]
    end
  end
end