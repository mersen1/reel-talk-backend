# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Services
        class Pagination
          def call(response)
            {
              page: response["page"].to_i,
              total_pages: response["total_pages"].to_i.clamp(0, 500),
              total_results: response["total_results"].to_i
            }
          end
        end
      end
    end
  end
end
