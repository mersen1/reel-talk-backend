# frozen_string_literal: true

require "dry/validation"

module Api
  module V1
    class TitlesContract < Dry::Validation::Contract
      MEDIA_TYPES = %w[tv].freeze
      STATUSES = %w[returning planned in_production ended cancelled].freeze
      SORTS = %w[popularity rating release_date].freeze
      MONETIZATION_TYPES = %w[flatrate free ads rent buy].freeze

      params do
        required(:language).filled(:string)
        required(:region).filled(:string)
        required(:page).filled(:integer)
        required(:media_type).filled(:string, included_in?: MEDIA_TYPES)
        required(:sort).filled(:string, included_in?: SORTS)
        optional(:origin_country).maybe(:string)
        optional(:genre_id).maybe(:integer)
        optional(:year_from).maybe(:integer)
        optional(:year_to).maybe(:integer)
        optional(:status).maybe(:string, included_in?: STATUSES)
        optional(:min_rating).maybe(:float)
        optional(:provider_id).maybe(:integer)
        optional(:monetization_type).maybe(:string, included_in?: MONETIZATION_TYPES)
      end

      rule(:page) { key.failure("must be between 1 and 500") unless (1..500).cover?(value) }
      rule(:year_from) { key.failure("must be between 1874 and 2100") if value && !(1874..2100).cover?(value) }
      rule(:year_to) { key.failure("must be between 1874 and 2100") if value && !(1874..2100).cover?(value) }
      rule(:min_rating) { key.failure("must be between 0 and 10") if value && !value.between?(0, 10) }
      rule(:year_from, :year_to) do
        if values[:year_from] && values[:year_to] && values[:year_from] > values[:year_to]
          key(:year_from).failure("must not be greater than year_to")
        end
      end
    end
  end
end
