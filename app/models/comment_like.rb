class CommentLike < ApplicationRecord
  belongs_to :comment
  validates :device_id, presence: true
  validates :device_id, uniqueness: { scope: :comment_id }
end
