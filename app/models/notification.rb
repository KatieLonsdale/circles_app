class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  validates_presence_of :message, :action
  
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :newest_first, -> { order(created_at: :desc, id: :desc) }
  
  # Mark notification as read
  def mark_as_read!
    update!(read: true)
  end
  
  # Helper method to get circle name if circle_id is present
  def circle_name
    Circle.find_by(id: circle_id)&.name if circle_id.present?
  end
end
