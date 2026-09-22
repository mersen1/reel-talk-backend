# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Mappers
        class Title
          def initialize(image_url:)
            @image_url = image_url
          end

          def call(item, media_type: nil)
            type = media_type || item["media_type"] || infer_media_type(item)
            date = type == "tv" ? item["first_air_date"] : item["release_date"]
            {
              id: item["id"],
              media_type: type,
              title: type == "tv" ? item["name"] : item["title"],
              original_title: type == "tv" ? item["original_name"] : item["original_title"],
              release_date: date,
              year: date.to_s[0, 4].to_i.presence,
              overview: item["overview"],
              poster_url: @image_url.call(item["poster_path"], "w500"),
              backdrop_url: @image_url.call(item["backdrop_path"], "w1280"),
              rating: item["vote_average"],
              vote_count: item["vote_count"],
              genre_ids: item["genre_ids"] || Array(item["genres"]).filter_map { |genre| genre["id"] },
              origin_countries: origin_countries(item)
            }
          end

          private

          def infer_media_type(item)
            return "tv" if item.key?("name") || item.key?("first_air_date")

            "movie" if item.key?("title") || item.key?("release_date")
          end

          def origin_countries(item)
            item["origin_country"] || item["origin_countries"] ||
              Array(item["production_countries"]).filter_map { |country| country["iso_3166_1"] }
          end
        end
      end
    end
  end
end
