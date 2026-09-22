# frozen_string_literal: true

require "dry/types"

module Api
  module V1
    module Types
      include Dry.Types()

      StrippedString = Types::String.constructor(&:strip)
    end
  end
end
