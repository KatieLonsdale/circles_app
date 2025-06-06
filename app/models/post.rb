class Post < ApplicationRecord
  belongs_to :circle
  has_many :comments, dependent: :destroy
  has_many :post_user_reactions, dependent: :destroy
  has_many :content, dependent: :destroy
  has_many :comment_user_reactions, through: :comments
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates_presence_of :circle_id
  validates_presence_of :author_id

  def owner_or_author?(user_id)
    author_id == user_id || circle.user_id == user_id
  end

  def author_display_name
    User.find(author_id).display_name
  end

  def top_level_comments
    comments.where(parent_comment_id: nil)
  end
end
