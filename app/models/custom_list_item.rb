# frozen_string_literal: true

class CustomListItem < ApplicationRecord
  belongs_to :custom_list

  validates :media_type, inclusion: { in: %w[tv] }
  validates :title_id, numericality: { only_integer: true, greater_than: 0 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :title_id, uniqueness: { scope: [:custom_list_id, :media_type] }
  validate :item_limit, on: :create

  private

  def item_limit
    errors.add(:base, "Too many titles") if custom_list.items.count >= 100
  end
end
