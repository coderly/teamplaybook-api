module TeamPlaybook
  module Scenario
    class UpdatePage

      def call(page:, page_params:)
        page.title = page_params[:title] if page_params.key? :title
        page.body = page_params[:body] if page_params.key? :body
        page.save

        page
      end
    end
  end
end
