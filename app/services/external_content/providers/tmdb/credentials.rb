# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      class Credentials
        def initialize(environment: ENV, credentials: Rails.application.credentials)
          @environment = environment
          @credentials = credentials
        end

        def call
          {
            access_token: @environment["TMDB_ACCESS_TOKEN"].presence || credential(:access_token),
            api_key: @environment["TMDB_API_KEY"].presence || credential(:api_key)
          }
        end

        private

        def credential(key)
          @credentials.dig(:tmdb, key).presence
        end
      end
    end
  end
end
