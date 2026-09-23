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
            titles = Array(grouped["tv"]).select { |item| korean_series?(item) }
            people = Array(grouped["person"]).filter_map { |person| korean_person(person) }
            {
              titles: @title_collection.call(titles),
              people: people.map { |person| @person_summary.call(person) },
              pagination: @pagination.call(response)
            }
          end

          private

          def korean_series?(item)
            KoreanSeries.include?(item)
          end

          def korean_person(person)
            known_for = Array(person["known_for"]).select { |title| korean_series?(title) }
            person.merge("known_for" => known_for) if known_for.any?
          end
        end
      end
    end
  end
end
