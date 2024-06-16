class Circle < ApplicationRecord
  belongs_to :user
  has_many :posts, dependent: :destroy
  has_many :comments, through: :posts
  has_many :post_user_reactions, through: :posts
  has_many :content, through: :posts
  has_many :circle_members, dependent: :destroy

  validates_presence_of :name
  validates_presence_of :user_id
  validates_presence_of :description

  def verify_member(user_id)
    circle_members.exists?(user_id: user_id) || owner?(user_id)
  end

  def owner?(user_id)
    user_id == user.id
  end
end
