# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Mappers
        class WatchProviders
          TYPES = %w[flatrate free ads rent buy].freeze

          def initialize(image_url:)
            @image_url = image_url
          end

          def call(data)
            TYPES.to_h do |type|
              [type, Array(data[type]).map { |provider| provider(provider) }]
            end
          end

          private

          def provider(item)
            {
              id: item["provider_id"],
              name: item["provider_name"],
              logo_url: @image_url.call(item["logo_path"], "original"),
              display_priority: item["display_priority"]
            }
          end
        end
      end
    end
  end
end
