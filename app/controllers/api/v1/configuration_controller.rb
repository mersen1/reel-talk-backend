# frozen_string_literal: true

module Api
  module V1
    class ConfigurationController < ApplicationController
      include RequestParameters

      def show
        render json: external_content.configuration(**validated_params(ConfigurationContract, defaults: request_defaults.slice(:language, :region)))
      end
    end
  end
end
