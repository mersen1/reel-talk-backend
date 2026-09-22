# frozen_string_literal: true

require "dry/validation"

module Api
  module V1
    class SeasonContract < Dry::Validation::Contract
      params do
        required(:id).filled(:integer, gt?: 0)
        required(:season_number).filled(:integer, gteq?: 0)
        required(:language).filled(:string)
      end
    end
  end
end
