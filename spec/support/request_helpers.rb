require 'hashie'

module Requests
  module JsonHelpers
    def json
      Hashie::Mash.new JSON.parse(response.body)
    end
  end

  module AuthorizationHelpers
    def token_authorize(token, email)
      header("X-User-Email", email)
      header("X-User-Token", token)
    end
  
    def token_unauthorize!
      header("X-User-Email", nil)
      header("X-User-Token", nil)
    end
  end
end