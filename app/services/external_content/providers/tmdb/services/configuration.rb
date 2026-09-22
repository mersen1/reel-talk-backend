# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Services
        class Configuration
          SORT_OPTIONS = %w[popularity rating release_date].freeze
          MEDIA_TYPES = %w[tv movie all].freeze
          MONETIZATION_TYPES = %w[flatrate free ads rent buy].freeze

          def initialize(client:, provider_collection:)
            @client = client
            @provider_collection = provider_collection
          end

          def call(language:, region:)
            {
              genres: genres(language),
              countries: countries(language),
              watch_providers: providers(language, region),
              sort_options: SORT_OPTIONS,
              media_types: MEDIA_TYPES,
              monetization_types: MONETIZATION_TYPES
            }
          end

          private

          def genres(language)
            {
              movie: @client.call("genre/movie/list", language:)["genres"] || [],
              tv: @client.call("genre/tv/list", language:)["genres"] || []
            }
          end

          def countries(language)
            @client.call("configuration/countries", language:).map do |country|
              { code: country["iso_3166_1"], name: country["native_name"] || country["english_name"] }
            end
          end

          def providers(language, region)
            movie = @client.call("watch/providers/movie", language:, watch_region: region)["results"]
            tv = @client.call("watch/providers/tv", language:, watch_region: region)["results"]
            @provider_collection.call(movie, tv)
          end
        end
      end
    end
  end
end
