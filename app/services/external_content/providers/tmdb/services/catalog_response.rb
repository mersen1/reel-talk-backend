# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Services
        class CatalogResponse
          def initialize(title_mapper:)
            @title_mapper = title_mapper
          end

          def call(responses:, page:, sort:)
            { titles: titles(responses, sort), pagination: pagination(responses, page) }
          end

          private

          def titles(responses, sort)
            items = responses.flat_map do |type, response|
              Array(response["results"]).filter_map do |raw|
                [@title_mapper.call(raw, media_type: type), raw] if KoreanSeries.include?(raw, media_type: type)
              end
            end
            items = sorted(items, sort) unless responses.one?
            items.map(&:first)
          end

          def pagination(responses, page)
            {
              page:,
              total_pages: responses.map { |_, data| data["total_pages"].to_i }.max.to_i.clamp(0, 500),
              total_results: responses.sum { |_, data| data["total_results"].to_i }
            }
          end

          def sorted(entries, sort)
            return entries.sort_by { |item, _| [-item[:rating].to_f, -item[:vote_count].to_i] } if sort == "rating"
            return entries.sort_by { |item, _| item[:release_date].to_s }.reverse if sort == "release_date"

            entries.sort_by { |_, raw| -raw["popularity"].to_f }
          end
        end
      end
    end
  end
end
