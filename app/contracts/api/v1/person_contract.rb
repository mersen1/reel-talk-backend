# frozen_string_literal: true

require "dry/validation"

module Api
  module V1
    class PersonContract < Dry::Validation::Contract
      params do
        required(:id).filled(:integer, gt?: 0)
        required(:language).filled(:string)
      end
    end
  end
end
