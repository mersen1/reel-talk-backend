# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Mappers
        class Trailer
          def call(videos)
            candidates = Array(videos).select { |video| video["site"] == "YouTube" }
            video = preferred(candidates)
            return unless video

            {
              name: video["name"],
              site: video["site"],
              key: video["key"],
              url: "https://www.youtube.com/watch?v=#{video['key']}"
            }
          end

          private

          def preferred(candidates)
            candidates.find { |video| video["type"] == "Trailer" && video["official"] } ||
              candidates.find { |video| video["type"] == "Trailer" } || candidates.first
          end
        end
      end
    end
  end
end
