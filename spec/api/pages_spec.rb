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

      post_json_api "/pages",
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

      post_json_api "/pages",
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

  describe 'PATCH /pages/:id' do

    it "should return a 403 Forbidden when accessed from a regular subdomain" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      page = create(:page, title: "Test page", body: "Test page body", root_node: true, team: team)

      host! "www.example.com"

      patch_json_api "/pages/#{page.id}", {
        data: {
          title: "Edited title",
          body: "Edited body"
        }
      }, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(response.code).to eq "403"
    end

    it "should return a 401 Not Authorized when requested by an anonymous user" do
      owner = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      page = create(:page, title: "Test page", body: "Test page body", root_node: true, team: team)

      host! "#{team.subdomain}.example.com"

      patch_json_api "/pages/#{page.id}", {
        data: {
          title: "Edited title",
          body: "Edited body"
        }
      }

      expect(response.code).to eq "401"
    end

    it "should return a 401 Not Authorized when requested by a user who isn't a team member" do
      owner = create(:user)
      other_user = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)

      page = create(:page, title: "Test page", body: "Test page body", root_node: true, team: team)

      host! "#{team.subdomain}.example.com"

      patch_json_api "/pages/#{page.id}", {
        data: {
          title: "Edited title",
          body: "Edited body"
        }
      }, {"X-User-Email" => other_user.email, "X-User-Token" => other_user.authentication_token}

      expect(response.code).to eq "401"
    end

    it "should update the page when requested by a team member" do
      owner = create(:user)
      team_member = create(:user)
      team = create(:team, owner: owner)
      create(:team_membership, user: owner, team: team, role: :owner)
      create(:team_membership, user: team_member, team: team, role: :member)
      page = create(:page, title: "Test page", body: "Test page body", root_node: true, team: team)

      host! "#{team.subdomain}.example.com"

      patch_json_api "/pages/#{page.id}", {
        data: {
          title: "Edited title",
          body: "Edited body"
        }
      }, {"X-User-Email" => team_member.email, "X-User-Token" => team_member.authentication_token}

      expect(response.code).to eq "200"

      get "/pages/", {}, {"X-User-Email" => team_member.email, "X-User-Token" => team_member.authentication_token}

      expect(json.data.count).to eq 1
      expect(json.data.first.title).to eq "Edited title"
      expect(json.data.first.body).to eq "Edited body"
    end
  end

  describe "DELETE /pages/:id" do
    it "should delete a page" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create(:team_membership, team: team, user: owner, role: :owner)

      page = create(:page, title: "root_node Test page", team: team)

      host! "test.example.com"

      get "/pages", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.size).to eq 1

      delete "/pages/#{page.id}", {},
       {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(response.code).to eq "204"

      get "/pages", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.size).to eq 0
    end

    it "should delete the child pages" do
      owner = create(:user)
      team = create(:team, subdomain: "test", owner: owner)
      create(:team_membership, team: team, user: owner, role: :owner)

      root_page = create(:page, title: "root_node Test page", team: team, root_node: true)
      create(:page, title: "Child page 1", team: team, parent: root_page)
      create(:page, title: "Child page 2", team: team, parent: root_page)

      create(:page, title: "Another root test page", team: team, root_node: true)

      host! "test.example.com"

      get "/pages", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.size).to eq 4

      delete "/pages/#{root_page.id}", {},
       {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(response.code).to eq "204"

      get "/pages", {}, {"X-User-Email" => owner.email, "X-User-Token" => owner.authentication_token}

      expect(json.data.size).to eq 1
    end

  end

end
