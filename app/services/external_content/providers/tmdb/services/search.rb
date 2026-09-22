# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Services
        class Search
          def initialize(client:, title_collection:, person_summary:, pagination:)
            @client = client
            @title_collection = title_collection
            @person_summary = person_summary
            @pagination = pagination
          end

          def call(query:, page:, language:, include_adult:)
            response = @client.call("search/multi", query:, page:, language:, include_adult:)
            grouped = Array(response["results"]).group_by { |item| item["media_type"] }
            {
              titles: @title_collection.call(Array(grouped["tv"]) + Array(grouped["movie"])),
              people: Array(grouped["person"]).map { |person| @person_summary.call(person) },
              pagination: @pagination.call(response)
            }
          end
        end
      end
    end
  end
end
