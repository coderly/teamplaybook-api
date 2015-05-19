require 'rails_helper'

describe 'Pages service' do
  describe 'GET /pages' do
    it "should return all plans" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
   
      create(:page, title: "Test page", root: true, team: team)
      create(:page, title: "Test page 2", root: true, team: team)

      get "/pages", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.size).to eq 2
      expect(json.data.first.title).to eq "Test page"
      expect(json.data.first.title).to eq "Test page 2"
    end

    it "should return the pages with the children ids" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
   
      root_page = create(:page, title: "Root Test page", root: true, team: team)
      child_page = create(:page, title: "Child page 1", root: true, team: team, parent: root_page)
      child_page2 = create(:page, title: "Child page 2", root: true, team: team, parent: root_page)

      get "/pages", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.size).to eq 3
      expect(json.data.first.links.children.map(&:id)).to match_array [child_page.id, child_page2.id]
    end
  end
end