class Comment < ApplicationRecord
  belongs_to :post
  has_many :comment_user_reactions, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  belongs_to :user, foreign_key: :author_id

  validates_presence_of :post_id
  validates_presence_of :author_id
  validates_presence_of :comment_text

  def author_display_name
    User.find(author_id).display_name
  end

  def replies
    Comment.where(parent_comment_id: id)
  end
end
