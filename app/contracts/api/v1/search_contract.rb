# frozen_string_literal: true

require "dry/validation"

module Api
  module V1
    class SearchContract < Dry::Validation::Contract
      params do
        required(:query).value(Types::StrippedString)
        required(:language).filled(:string)
        required(:page).filled(:integer)
        required(:include_adult).filled(:bool)
      end

      rule(:page) { key.failure("must be between 1 and 500") unless (1..500).cover?(value) }
      rule(:query) { key.failure("must not be empty") if value.empty? }
    end
  end
end
