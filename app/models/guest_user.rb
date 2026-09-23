# frozen_string_literal: true

class GuestUser < ApplicationRecord
  after_create { update_column(:display_name, "Гость #{id}") }
  validates :device_id, presence: true, uniqueness: true
  validates :display_name, presence: true, length: { maximum: 80 }
end
