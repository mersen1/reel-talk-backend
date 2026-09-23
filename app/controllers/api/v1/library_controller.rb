# frozen_string_literal: true

module Api
  module V1
    class LibraryController < ApplicationController
      include InteractionRequest

      def index
        owner = device_id
        return unless owner

        render json: { entries: LibraryEntry.where(device_id: owner).order(updated_at: :desc).map { |entry| serialize(entry) } }
      end

      def update
        owner = device_id
        key = title_key
        return unless owner && key

        entry = LibraryEntry.find_or_initialize_by(device_id: owner, media_type: key[0], title_id: key[1])
        values = params.permit(:status, :user_rating, :favorite, :personal_note, watched_episodes: [], episode_ratings: {}, episode_watched_at: {}).to_h
        entry.assign_attributes(values)
        entry.save ? render(json: serialize(entry)) : invalid_record(entry)
      end

      def destroy
        owner = device_id
        key = title_key
        return unless owner && key

        LibraryEntry.where(device_id: owner, media_type: key[0], title_id: key[1]).delete_all
        head :no_content
      end

      private

      def serialize(entry)
        { media_type: entry.media_type, title_id: entry.title_id, status: entry.status,
          user_rating: entry.user_rating, favorite: entry.favorite, personal_note: entry.personal_note,
          watched_episodes: entry.watched_episodes,
          episode_ratings: entry.episode_ratings,
          episode_watched_at: entry.episode_watched_at,
          updated_at: entry.updated_at.iso8601 }
      end
    end
  end
end
