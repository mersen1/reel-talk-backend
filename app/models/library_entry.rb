class LibraryEntry < ApplicationRecord
  validates :device_id, presence: true
  validates :media_type, inclusion: { in: %w[tv movie] }
  validates :title_id, numericality: { only_integer: true, greater_than: 0 }
  validates :status, inclusion: { in: %w[WANT_TO_WATCH WATCHING ON_HOLD DROPPED COMPLETED] }, allow_nil: true
  validates :user_rating, inclusion: { in: 1..10 }, allow_nil: true
  validates :personal_note, length: { maximum: 5000 }
end
