require 'hashie'

module Requests
  module JsonHelpers
    def json
      Hashie::Mash.new JSON.parse(response.body)
    end
  end
end