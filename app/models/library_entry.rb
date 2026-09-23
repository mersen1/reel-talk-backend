# frozen_string_literal: true

class LibraryEntry < ApplicationRecord
  validates :device_id, presence: true
  validates :media_type, inclusion: { in: %w[tv movie] }
  validates :title_id, numericality: { only_integer: true, greater_than: 0 }
  validates :status, inclusion: { in: %w[WANT_TO_WATCH WATCHING ON_HOLD DROPPED COMPLETED] }, allow_nil: true
  validates :user_rating, inclusion: { in: 1..10 }, allow_nil: true
  validates :personal_note, length: { maximum: 5000 }
  validate :valid_watched_episodes
  validate :valid_episode_ratings
  validate :valid_episode_watched_at

  private

  def valid_watched_episodes
    return if watched_episodes.is_a?(Array) && watched_episodes.length <= 1000 &&
      watched_episodes.all? { |key| key.is_a?(String) && key.match?(/\A[1-9]\d*:[1-9]\d*\z/) } &&
      watched_episodes.uniq.length == watched_episodes.length

    errors.add(:watched_episodes, "must contain unique season:episode identifiers")
  end

  def valid_episode_ratings
    return if episode_ratings.is_a?(Hash) && episode_ratings.length <= 1000 &&
      episode_ratings.all? { |key, rating| key.match?(/\A[1-9]\d*:[1-9]\d*\z/) && rating.is_a?(Integer) && rating.between?(1, 10) }

    errors.add(:episode_ratings, "must map season:episode identifiers to ratings from 1 to 10")
  end

  def valid_episode_watched_at
    return if episode_watched_at.is_a?(Hash) && episode_watched_at.length <= 1000 &&
      episode_watched_at.all? { |key, value| key.match?(/\A[1-9]\d*:[1-9]\d*\z/) && value.is_a?(Integer) && value.positive? }

    errors.add(:episode_watched_at, "must map season:episode identifiers to timestamps")
  end
end
