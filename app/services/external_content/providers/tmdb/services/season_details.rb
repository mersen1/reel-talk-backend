# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Services
        class SeasonDetails
          def initialize(client:)
            @client = client
          end

          def call(id:, season_number:, language:)
            response = @client.call("tv/#{id}/season/#{season_number}", language:)
            {
              season_number: response["season_number"],
              episodes: Array(response["episodes"]).filter_map do |episode|
                number = episode["episode_number"]
                next unless number.is_a?(Integer) && number.positive?

                {
                  number: number,
                  name: episode["name"].to_s,
                  overview: episode["overview"].to_s,
                  air_date: episode["air_date"],
                  runtime_minutes: episode["runtime"]
                }
              end
            }
          end
        end
      end
    end
  end
end
