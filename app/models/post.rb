class Post < ApplicationRecord
  belongs_to :circle
  has_many :comments, dependent: :destroy
  has_many :post_user_reactions, dependent: :destroy
  has_many :content, dependent: :destroy
  has_many :comment_user_reactions, through: :comments

  validates_presence_of :circle_id
  validates_presence_of :author_id

  def owner_or_author?(user_id)
    author_id == user_id || circle.user_id == user_id
  end
end
