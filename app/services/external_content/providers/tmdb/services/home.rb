# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Services
        class Home
          def initialize(client:, title_collection:)
            @client = client
            @title_collection = title_collection
          end

          def call(language:, region:, page:)
            popular = discover(language, page, "popularity.desc")
            trending = mapped("trending/tv/week", { language:, page: }, media_type: "tv")
            releases = discover(language, page, "first_air_date.desc", "first_air_date.lte": Date.current.iso8601)
            recommendations = discover(language, page, "vote_average.desc", "vote_count.gte": 100)
            featured = popular.find { |title| title[:rating].to_f >= 8 && title[:vote_count].to_i >= 100 } ||
              recommendations.first || popular.first

            {
              featured:,
              trending: trending.presence || popular,
              popular:,
              new_releases: releases,
              recommendations:
            }
          end

          private

          def discover(language, page, sort, extra = {})
            params = { language:, page:, sort_by: sort, with_origin_country: "KR",
                       without_genres: KoreanSeries::EXCLUDED_GENRE_IDS.join(","), include_adult: false }.merge(extra)
            mapped("discover/tv", params, media_type: "tv")
          end

          def mapped(path, params, media_type: nil)
            raw = Array(@client.call(path, params)["results"])
            @title_collection.call(raw.select { |item| KoreanSeries.include?(item, media_type: media_type || "tv") }, media_type: media_type)
          end
        end
      end
    end
  end
end
