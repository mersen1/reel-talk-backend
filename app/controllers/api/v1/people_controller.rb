# frozen_string_literal: true

module Api
  module V1
    class PeopleController < ApplicationController
      include RequestParameters

      def show
        render json: external_content.person(**validated_params(PersonContract, defaults: request_defaults.slice(:language)))
      end
    end
  end
end
