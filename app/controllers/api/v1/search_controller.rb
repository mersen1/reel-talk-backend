# frozen_string_literal: true

module Api
  module V1
    class SearchController < ApplicationController
      include RequestParameters

      def show
        render json: external_content.search(**validated_params(SearchContract, defaults: request_defaults.slice(:language, :page).merge(include_adult: false)))
      end
    end
  end
end
