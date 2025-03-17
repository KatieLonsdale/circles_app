class User < ApplicationRecord
  has_many :circles, dependent: :destroy
  has_many :circle_members, dependent: :destroy
  
  # Friendship associations
  has_many :friendships, dependent: :destroy
  has_many :friends, -> { where(friendships: { status: :accepted }) }, through: :friendships
  has_many :pending_friends, -> { where(friendships: { status: :pending }) }, through: :friendships, source: :friend
  has_many :rejected_friends, -> { where(friendships: { status: :rejected }) }, through: :friendships, source: :friend
  
  # Inverse friendship associations
  # todo: not sure if this is a valid thing
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy
  has_many :inverse_friends, -> { where(friendships: { status: :accepted }) }, through: :inverse_friendships, source: :user
  has_many :pending_inverse_friends, -> { where(friendships: { status: :pending }) }, through: :inverse_friendships, source: :user
  has_many :rejected_inverse_friends, -> { where(friendships: { status: :rejected }) }, through: :inverse_friendships, source: :user

  enum notification_frequency: { live: 0, hourly: 1, daily: 2 }

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_secure_password
  validates :email, 
            uniqueness: { case_sensitive: false},
            format: { with: EMAIL_REGEX, message: "must be a valid email address" }
  validates :email, presence: true, on: :create
  validates :notifications_token, presence: true, on: :create
  validates_presence_of :password,
                        on: :create
  validates_presence_of :display_name,
                        on: :create

  # Search users by display_name
  def self.search(query)
    puts "query: #{query}"
    return nil if query.blank?
    where("display_name ILIKE ?", "%#{query}%")
  end

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
  
  # Friendship methods
  def all_friends
    friends + inverse_friends
  end
  
  def all_pending_friends
    pending_friends + pending_inverse_friends
  end
  
  def friend_request(user)
    friendships.create(friend: user)
  end
  
  def accept_friend_request(user)
    request = inverse_friendships.find_by(user: user)
    request.accepted! if request
  end
  
  def reject_friend_request(user)
    request = inverse_friendships.find_by(user: user)
    request.rejected! if request
  end
  
  def remove_friend(user)
    friendship = friendships.find_by(friend: user)
    inverse_friendship = inverse_friendships.find_by(user: user)
    
    friendship.destroy if friendship
    inverse_friendship.destroy if inverse_friendship
  end
  
  def friends_with?(user)
    friends.include?(user) || inverse_friends.include?(user)
  end
  
  def pending_friend_request_from?(user)
    pending_inverse_friends.include?(user)
  end
  
  def pending_friend_request_to?(user)
    pending_friends.include?(user)
  end
end
