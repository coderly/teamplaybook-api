module TeamPlaybook
  module Scenario
    class CreatePage
      def call(team:, page_params:)
        page = new_page_for_team(team, page_params)
        page.save
        page     
      end

      private

      def new_page_for_team(team, params)
        page = Page.new(params)
        page.team = team
        page.root_node = page.parent.nil?
        page
      end


    end
  end
end