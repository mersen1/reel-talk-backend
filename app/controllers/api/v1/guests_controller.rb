module Api
  module V1
    class GuestsController < ApplicationController
      include InteractionRequest

      def show
        owner = device_id
        return unless owner

        guest = GuestUser.find_by!(device_id: owner)
        render json: { id: guest.id, display_name: guest.display_name, temporary: true }
      end
    end
  end
end
