# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Mappers
        class ImageUrl
          BASE_URL = "https://image.tmdb.org/t/p"

          def call(path, size)
            "#{BASE_URL}/#{size}#{path}" if path.present?
          end
        end
      end
    end
  end
end
