# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Mappers
        class TitleCollection
          def initialize(title:)
            @title = title
          end

          def call(items, media_type: nil)
            Array(items).filter_map do |item|
              type = media_type || item["media_type"] || infer_media_type(item)
              @title.call(item, media_type: type) if %w[tv movie].include?(type)
            end
          end

          private

          def infer_media_type(item)
            return "tv" if item.key?("name") || item.key?("first_air_date")

            "movie" if item.key?("title") || item.key?("release_date")
          end
        end
      end
    end
  end
end
