# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Mappers
        class Person
          def initialize(title_collection:, image_url:)
            @title_collection = title_collection
            @image_url = image_url
          end

          def call(item)
            filmography = @title_collection.call(item.dig("combined_credits", "cast"))
              .sort_by { |credit| credit[:release_date].to_s }.reverse
            {
              id: item["id"],
              name: item["name"],
              original_name: item["original_name"] || item["name"],
              biography: item["biography"],
              birthday: item["birthday"],
              deathday: item["deathday"],
              place_of_birth: item["place_of_birth"],
              profile_url: @image_url.call(item["profile_path"], "h632"),
              popularity: item["popularity"],
              tv: filmography.select { |credit| credit[:media_type] == "tv" },
              movies: filmography.select { |credit| credit[:media_type] == "movie" },
              filmography:
            }
          end
        end
      end
    end
  end
end
