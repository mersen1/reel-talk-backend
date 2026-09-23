# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :comment_likes, dependent: :destroy
  validates :device_id, :user_name, :body, presence: true
  validates :body, length: { maximum: 5000 }
  validates :user_name, length: { maximum: 80 }
  validates :media_type, inclusion: { in: %w[tv movie] }
  validates :title_id, numericality: { only_integer: true, greater_than: 0 }
  validates :season_number, :episode_number, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :episode_scope_complete
  validate :parent_matches_title

  private

  def episode_scope_complete
    errors.add(:episode_number, "requires a season") if season_number.nil? != episode_number.nil?
    errors.add(:media_type, "must be tv for an episode") if season_number && media_type != "tv"
  end

  def parent_matches_title
    errors.add(:parent, "not found") if parent_id.present? && parent.nil?
    errors.add(:parent, "must belong to the same title") if parent && (parent.media_type != media_type || parent.title_id != title_id)
    errors.add(:parent, "must belong to the same episode") if parent && (parent.season_number != season_number || parent.episode_number != episode_number)
  end
end
