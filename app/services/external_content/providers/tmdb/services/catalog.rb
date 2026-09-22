# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Services
        class Catalog
          def initialize(client:, query:, response:)
            @client = client
            @query = query
            @response = response
          end

          def call(media_type:, page:, language:, region:, **filters)
            responses = requested_types(media_type, filters).map do |type|
              [type, fetch(type, page, language, region, filters)]
            end

            @response.call(responses:, page:, sort: filters[:sort])
          end

          private

          def requested_types(media_type, filters)
            return ["tv"] if media_type == "all" && filters[:status].present?

            media_type == "all" ? %w[tv movie] : [media_type]
          end

          def fetch(type, page, language, region, filters)
            query = @query.call(type:, page:, language:, region:, filters:)
            @client.call("discover/#{type}", query)
          end
        end
      end
    end
  end
end
