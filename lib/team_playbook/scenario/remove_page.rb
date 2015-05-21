module TeamPlaybook
  module Scenario
    class RemovePage

      def call(page)
        page.destroy
        page
      end
    end
  end
end
