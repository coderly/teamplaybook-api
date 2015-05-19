require 'rails_helper'

describe 'Pages service' do
  describe 'GET /pages' do
    it "should return all pages" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create(:team_membership, team: team, user: owner, role: :owner)

      create(:page, title: "Test page", root_node: true, team: team)
      create(:page, title: "Test page 2", root_node: true, team: team)

      host! "test.example.com"

      get "/pages", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}
      expect(json.data.size).to eq 2
      expect(json.data.map(&:title)).to match_array ["Test page", "Test page 2"]
    end

    it "should return the pages with the children ids" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create(:team_membership, team: team, user: owner, role: :owner)

      root_node_page = create(:page, title: "root_node Test page", root_node: true, team: team)
      child_page = create(:page, title: "Child page 1", root_node: true, team: team, parent: root_node_page)
      child_page2 = create(:page, title: "Child page 2", root_node: true, team: team, parent: root_node_page)

      host! "test.example.com"

      get "/pages", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}
      expect(json.data.size).to eq 3
      expect(json.data.first.links.children.linkage.map(&:id)).to match_array [child_page.id.to_s, child_page2.id.to_s]
    end
  end

  describe 'POST /pages' do
    it "should create a page" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create(:team_membership, team: team, user: owner, role: :owner)

      host! "test.example.com"

      post "/pages",
       {data: {
        title: "Test page",
        body: "test page body"
        }
       },
       {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}
      
      expect(json.data.title).to eq "Test page"
      expect(json.data.body).to eq "test page body"
      expect(json.data.root_node).to eq true
    end

    it "should create a child page" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create(:team_membership, team: team, user: owner, role: :owner)

      root_node_page = create(:page, title: "root_node Test page", root_node: true, team: team)

      host! "test.example.com"

      post "/pages",
       {data: {
        title: "Test page",
        body: "test page body",
        parent_id: root_node_page.id
        }
       },
       {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}
      
      expect(json.data.title).to eq "Test page"
      expect(json.data.body).to eq "test page body"
      expect(json.data.root_node).to eq false

      child_page_id = json.data.id

      get "/pages", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.size).to eq 2
      expect(json.data.first.links.children.linkage.first.id).to eq child_page_id
    end
  end

end