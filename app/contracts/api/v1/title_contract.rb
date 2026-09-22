# frozen_string_literal: true

require "dry/validation"

module Api
  module V1
    class TitleContract < Dry::Validation::Contract
      params do
        required(:media_type).filled(:string)
        required(:id).filled(:integer, gt?: 0)
        required(:language).filled(:string)
        required(:region).filled(:string)
      end

      rule(:media_type) { key.failure("must be tv or movie") unless %w[tv movie].include?(value) }
    end
  end
end
