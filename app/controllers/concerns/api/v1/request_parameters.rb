# frozen_string_literal: true

module Api
  module V1
    module RequestParameters
      extend ActiveSupport::Concern

      private

      def validated_params(contract_class, defaults: {})
        input = defaults.merge(params.to_unsafe_h.symbolize_keys)
        result = contract_class.new.call(input)
        return result.to_h if result.success?

        error = result.errors.first
        parameter = error.path.first
        raise ExternalContent::InvalidParameter.new("#{parameter} #{error.text}", parameter:)
      end

      def request_defaults
        {
          language: "ru-RU",
          region: ENV.fetch("TMDB_DEFAULT_REGION", "RU"),
          page: 1
        }
      end
    end
  end
end
