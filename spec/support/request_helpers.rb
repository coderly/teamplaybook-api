require 'hashie'

module Requests
  module JsonHelpers
    def json
      Hashie::Mash.new JSON.parse(response.body)
    end
  end

  module MimeHelpers
    def post_json_api(path, params={}, headers={})
      headers.merge!("Content-Type" => "application/vnd.api+json")
      post path, params.to_json, headers
    end

    def put_json_api(path, params={}, headers={})
      headers.merge!("Content-Type" => "application/vnd.api+json")
      post path, params.to_json, headers
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