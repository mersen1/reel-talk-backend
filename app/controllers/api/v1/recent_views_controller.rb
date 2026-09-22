module Api
  module V1
    class RecentViewsController < ApplicationController
      include InteractionRequest

      def index
        owner = device_id
        return unless owner

        render json: { title_ids: RecentView.where(device_id: owner).order(viewed_at: :desc).limit(10).map { |view| "#{view.media_type}:#{view.title_id}" } }
      end

      def update
        owner = device_id
        key = title_key
        return unless owner && key

        view = RecentView.find_or_initialize_by(device_id: owner, media_type: key[0], title_id: key[1])
        view.update!(viewed_at: Time.current)
        render json: { title_id: "#{view.media_type}:#{view.title_id}" }
      end
    end
  end
end
