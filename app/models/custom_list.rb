# frozen_string_literal: true

class CustomList < ApplicationRecord
  has_many :items, class_name: "CustomListItem", dependent: :destroy

  before_validation :assign_share_token, on: :create

  validates :device_id, presence: true
  validates :name, length: { in: 1..60 }
  validates :share_token, presence: true, uniqueness: true
  validate :list_limit, on: :create

  private

  def assign_share_token
    self.share_token ||= SecureRandom.urlsafe_base64(18)
  end

  def list_limit
    errors.add(:base, "Too many lists") if CustomList.where(device_id:).count >= 50
  end
end
