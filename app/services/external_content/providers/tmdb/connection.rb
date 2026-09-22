# frozen_string_literal: true

require "faraday"

module ExternalContent
  module Providers
    module Tmdb
      class Connection
        BASE_URL = "https://api.themoviedb.org/3/"

        def initialize(access_token: ENV["TMDB_ACCESS_TOKEN"], api_key: ENV["TMDB_API_KEY"])
          @access_token = access_token.presence
          @api_key = api_key.presence
        end

        def call
          raise ConfigurationError, "TMDB_ACCESS_TOKEN or TMDB_API_KEY must be configured" unless credentials?

          Faraday.new(url: BASE_URL, headers:, params:) do |connection|
            connection.options.open_timeout = 5
            connection.options.timeout = 10
            connection.response :json
          end
        end

        private

        def credentials?
          @access_token || @api_key
        end

        def headers
          result = { "Accept" => "application/json" }
          result["Authorization"] = "Bearer #{@access_token}" if @access_token
          result
        end

        def params
          @access_token ? {} : { api_key: @api_key }
        end
      end
    end
  end
end
