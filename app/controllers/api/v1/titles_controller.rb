# frozen_string_literal: true

module Api
  module V1
    class TitlesController < ApplicationController
      include RequestParameters

      def index
        defaults = request_defaults.merge(media_type: "all", origin_country: "KR", sort: "popularity")
        render json: external_content.titles(**validated_params(TitlesContract, defaults: defaults))
      end

      def show
        defaults = request_defaults.slice(:language, :region)
        render json: external_content.title(**validated_params(TitleContract, defaults: defaults))
      end
    end
  end
end
