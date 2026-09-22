# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Services
        class ProviderCollection
          def initialize(image_url:)
            @image_url = image_url
          end

          def call(*collections)
            unique_providers(collections).sort_by { |item| [item["display_priority"].to_i, item["provider_name"].to_s] }.map do |item|
              {
                id: item["provider_id"],
                name: item["provider_name"],
                logo_url: @image_url.call(item["logo_path"], "original"),
                display_priority: item["display_priority"]
              }
            end
          end

          private

          def unique_providers(collections)
            collections.flatten.compact.index_by { |item| item["provider_id"] }.values
          end
        end
      end
    end
  end
end
