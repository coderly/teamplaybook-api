require 'hashie'

module Requests
  module JsonHelpers
    def json
      Hashie::Mash.new JSON.parse(response.body)
    end
  end

  module AuthorizationHelpers
    def token_authorize(token, email)
      headers.merge!("X-User-Email" => email)
      headers.merge!("X-User-Token" => token)
    end
  
    def token_unauthorize!
      headers.delete "X-User-Email"
      headers.delete "X-User-Token"
    end
  end
end