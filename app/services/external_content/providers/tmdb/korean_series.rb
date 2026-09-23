# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module KoreanSeries
        EXCLUDED_GENRE_IDS = [16, 99, 10762, 10763, 10764, 10767].freeze

        def self.include?(item, media_type: nil)
          type = media_type || item["media_type"]
          countries = Array(item["origin_country"] || item["origin_countries"])
          genres = Array(item["genre_ids"]) + Array(item["genres"]).filter_map { |genre| genre["id"] if genre.is_a?(Hash) }

          type == "tv" && countries.include?("KR") && (genres.map(&:to_i) & EXCLUDED_GENRE_IDS).empty?
        end
      end
    end
  end
end
