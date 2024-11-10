class User < ApplicationRecord
  has_many :circles, dependent: :destroy
  has_many :circle_members, dependent: :destroy

  enum notification_frequency: { live: 0, hourly: 1, daily: 2 }

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_secure_password
  validates :email, 
            presence: true, 
            uniqueness: { case_sensitive: false},
            format: { with: EMAIL_REGEX, message: "must be a valid email address" }
  validates_presence_of :password
  validates_presence_of :display_name

  def get_all_circles
    owned_circles = circles
    circle_members = get_circle_member_circles
    all_circles = owned_circles + circle_members
    all_circles.uniq
  end

  def get_circle_member_circles
    Circle.joins(:circle_members).where("circle_members.user_id = ?", self.id)
  end

  def get_newsfeed
    circle_ids = get_all_circles.pluck(:id)
    Post.where(circle_id: circle_ids)
  end
end
