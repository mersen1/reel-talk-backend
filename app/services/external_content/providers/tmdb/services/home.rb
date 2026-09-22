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
            trending = mapped("trending/all/day", { language:, page: })
            popular = discover(language, page, "popularity.desc")
            releases = discover(language, page, "first_air_date.desc", "first_air_date.lte": Date.current.iso8601)
            recommendations = discover(language, page, "vote_average.desc", "vote_count.gte": 50)

            {
              featured: trending.first || popular.first,
              trending:,
              popular:,
              new_releases: releases,
              recommendations:
            }
          end

          private

          def discover(language, page, sort, extra = {})
            params = { language:, page:, sort_by: sort, with_origin_country: "KR", include_adult: false }.merge(extra)
            mapped("discover/tv", params, media_type: "tv")
          end

          def mapped(path, params, media_type: nil)
            @title_collection.call(@client.call(path, params)["results"], media_type:)
          end
        end
      end
    end
  end
end
