# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Mappers
        class TitleDetails
          def initialize(title:, title_collection:, image_url:, trailer:, watch_providers:)
            @title = title
            @title_collection = title_collection
            @image_url = image_url
            @trailer = trailer
            @watch_providers = watch_providers
          end

          def call(item, media_type:, region:)
            providers = item.dig("watch/providers", "results", region) || {}
            @title.call(item, media_type:).merge(
              status: item["status"],
              runtime_minutes: runtime(item, media_type),
              number_of_seasons: item["number_of_seasons"],
              number_of_episodes: item["number_of_episodes"],
              countries: countries(item, media_type),
              genres: genres(item),
              cast: cast(item),
              trailer: @trailer.call(item.dig("videos", "results")),
              similar: @title_collection.call(item.dig("similar", "results"), media_type:),
              recommendations: @title_collection.call(item.dig("recommendations", "results"), media_type:),
              watch_providers: @watch_providers.call(providers),
              watch_providers_url: providers["link"]
            )
          end

          private

          def countries(item, media_type)
            return Array(item["origin_country"]) if media_type == "tv"

            Array(item["production_countries"]).map do |country|
              { code: country["iso_3166_1"], name: country["name"] }
            end
          end

          def genres(item)
            Array(item["genres"]).map { |genre| { id: genre["id"], name: genre["name"] } }
          end

          def runtime(item, media_type)
            media_type == "tv" ? Array(item["episode_run_time"]).first : item["runtime"]
          end

          def cast(item)
            Array(item.dig("credits", "cast")).first(20).map do |person|
              {
                id: person["id"],
                name: person["name"],
                original_name: person["original_name"] || person["name"],
                character: person["character"],
                profile_url: @image_url.call(person["profile_path"], "h632")
              }
            end
          end
        end
      end
    end
  end
end
