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

      def season
        defaults = request_defaults.slice(:language)
        arguments = validated_params(SeasonContract, defaults: defaults)
        season = external_content.season(**arguments)
        counts = Comment.where(media_type: "tv", title_id: arguments[:id], season_number: arguments[:season_number])
          .group(:episode_number).count
        rating_totals = Hash.new { |totals, number| totals[number] = [0, 0] }
        prefix = "#{arguments[:season_number]}:"
        LibraryEntry.where(media_type: "tv", title_id: arguments[:id]).pluck(:episode_ratings).each do |ratings|
          ratings.each do |key, rating|
            next unless key.start_with?(prefix)

            number = key.delete_prefix(prefix).to_i
            rating_totals[number][0] += rating
            rating_totals[number][1] += 1
          end
        end
        render json: season.merge(episodes: season[:episodes].map { |episode|
          sum, count = rating_totals[episode[:number]]
          episode.merge(comment_count: counts.fetch(episode[:number], 0), rating_sum: sum, rating_count: count)
        })
      end
    end
  end
end
