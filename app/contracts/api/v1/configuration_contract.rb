# frozen_string_literal: true

require "dry/validation"

module Api
  module V1
    class ConfigurationContract < Dry::Validation::Contract
      params do
        required(:language).filled(:string)
        required(:region).filled(:string)
      end
    end
  end
end
