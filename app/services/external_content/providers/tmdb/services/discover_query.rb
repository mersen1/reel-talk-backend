# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Services
        class DiscoverQuery
          STATUS = { "returning" => 0, "planned" => 1, "in_production" => 2, "ended" => 3, "cancelled" => 4 }.freeze
          SORT = {
            "popularity" => { "tv" => "popularity.desc", "movie" => "popularity.desc" },
            "rating" => { "tv" => "vote_average.desc", "movie" => "vote_average.desc" },
            "release_date" => { "tv" => "first_air_date.desc", "movie" => "primary_release_date.desc" }
          }.freeze

          def call(type:, page:, language:, region:, filters:)
            common_params(type, page, language, region, filters)
              .merge(media_params(type, region, filters)).compact
          end

          private

          def common_params(type, page, language, region, filters)
            {
              language:,
              page:,
              include_adult: false,
              sort_by: SORT.fetch(filters[:sort] || "popularity").fetch(type),
              with_origin_country: filters[:origin_country],
              with_genres: filters[:genre_id],
              "vote_average.gte": filters[:min_rating],
              with_watch_providers: filters[:provider_id],
              with_watch_monetization_types: filters[:monetization_type],
              watch_region: watch_region(region, filters)
            }
          end

          def media_params(type, region, filters)
            type == "tv" ? tv_params(filters) : movie_params(region, filters)
          end

          def tv_params(filters)
            {
              "first_air_date.gte": boundary(filters[:year_from], "01-01"),
              "first_air_date.lte": boundary(filters[:year_to], "12-31"),
              with_status: STATUS[filters[:status]]
            }
          end

          def movie_params(region, filters)
            {
              region:,
              "primary_release_date.gte": boundary(filters[:year_from], "01-01"),
              "primary_release_date.lte": boundary(filters[:year_to], "12-31")
            }
          end

          def watch_region(region, filters)
            region if filters[:provider_id] || filters[:monetization_type]
          end

          def boundary(year, suffix)
            "#{year}-#{suffix}" if year
          end
        end
      end
    end
  end
end
