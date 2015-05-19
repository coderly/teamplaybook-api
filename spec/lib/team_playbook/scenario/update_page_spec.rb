require 'rails_helper'
require 'team_playbook/scenario/update_page'

module TeamPlaybook
  module Scenario
    describe UpdatePage do
      it "should modify page title and body" do
        user = create(:user)
        team = create(:team)
        create(:team_membership, user: user, team: team, email: user.email, role: :admin)

        page = create(:page, title: "Test page", body: "Test page body", root_node: true, team: team)

        page = UpdatePage.new.call(page: page, page_params: {title: "Edited title", body: "Edited body"})

        expect(page.title).to eq "Edited title"
        expect(page.body).to eq "Edited body"
        expect(page.valid?).to be true
        expect(page.persisted?).to be true
      end

      it "should not modify other page properties" do
        user = create(:user)
        team = create(:team)
        other_team = create(:team)
        create(:team_membership, user: user, team: team, email: user.email, role: :admin)

        parent = create(:page)
        page = create(:page, title: "Test page", body: "Test page body", root_node: true, team: team)

        page = UpdatePage.new.call(page: page, page_params: {team: other_team, parent: parent})

        expect(page.team).to eq team
        expect(page.parent).to be nil
        expect(page.valid?).to be true
        expect(page.persisted?).to be true
      end
    end
  end
end
