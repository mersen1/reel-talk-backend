# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      class Adapter < ExternalContent::Provider
        def initialize(operations:)
          @operations = operations
        end

        %i[home titles search title person configuration].each do |operation|
          define_method(operation) do |**params|
            @operations.fetch(operation).call(**params)
          end
        end
      end
    end
  end
end
