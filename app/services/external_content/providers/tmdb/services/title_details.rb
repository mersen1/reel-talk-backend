# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Services
        class TitleDetails
          APPEND = "credits,videos,similar,recommendations,watch/providers"

          def initialize(client:, mapper:)
            @client = client
            @mapper = mapper
          end

          def call(media_type:, id:, language:, region:)
            response = @client.call("#{media_type}/#{id}", language:, append_to_response: APPEND)
            raise ExternalContent::NotFound unless KoreanSeries.include?(response, media_type:)

            @mapper.call(response, media_type:, region:)
          end
        end
      end
    end
  end
end
