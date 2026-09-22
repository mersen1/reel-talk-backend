# frozen_string_literal: true

module Api
  module V1
    class HomeController < ApplicationController
      include RequestParameters

      def show
        render json: external_content.home(**validated_params(HomeContract, defaults: request_defaults))
      end
    end
  end
end
