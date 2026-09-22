# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      class Client
        def initialize(connection:)
          @connection = connection
        end

        def call(path, params = {})
          response = @connection.get(path, params.compact)
          handle(response)
        rescue Faraday::TimeoutError, Faraday::ConnectionFailed
          raise Unavailable.new(status: :service_unavailable)
        rescue Faraday::ParsingError
          raise Unavailable
        end

        private

        def handle(response)
          case response.status
          when 200..299 then response.body
          when 404 then raise NotFound
          when 429, 500..599 then raise Unavailable.new(status: :service_unavailable)
          else raise Unavailable
          end
        end
      end
    end
  end
end
