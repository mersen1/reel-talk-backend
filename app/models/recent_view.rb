class RecentView < ApplicationRecord
  validates :device_id, presence: true
  validates :media_type, inclusion: { in: %w[tv movie] }
  validates :title_id, numericality: { only_integer: true, greater_than: 0 }
end
