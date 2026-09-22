# frozen_string_literal: true

require "dry/validation"

module Api
  module V1
    class HomeContract < Dry::Validation::Contract
      params do
        required(:language).filled(:string)
        required(:region).filled(:string)
        required(:page).filled(:integer)
      end

      rule(:page) { key.failure("must be between 1 and 500") unless (1..500).cover?(value) }
    end
  end
end
