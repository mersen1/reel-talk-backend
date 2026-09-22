# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Mappers
        class PersonSummary
          def initialize(title_collection:, image_url:)
            @title_collection = title_collection
            @image_url = image_url
          end

          def call(item)
            {
              id: item["id"],
              name: item["name"],
              original_name: item["original_name"] || item["name"],
              profile_url: @image_url.call(item["profile_path"], "h632"),
              popularity: item["popularity"],
              known_for_department: item["known_for_department"],
              known_for: @title_collection.call(item["known_for"])
            }
          end
        end
      end
    end
  end
end
