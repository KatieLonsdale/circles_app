class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  enum status: { pending: 0, accepted: 1, rejected: 2 }

  validates :user_id, uniqueness: { scope: :friend_id, message: "friendship already exists" }
  validate :not_self_friendship

  scope :accepted, -> { where(status: :accepted) }
  scope :pending, -> { where(status: :pending) }
  scope :rejected, -> { where(status: :rejected) }

  private

  def not_self_friendship
    if user_id == friend_id
      errors.add(:friend_id, "can't be the same as user")
    end
  end
end
