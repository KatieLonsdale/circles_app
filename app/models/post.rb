class Post < ApplicationRecord
  belongs_to :circle
  has_many :comments, dependent: :destroy
  has_many :post_user_reactions, dependent: :destroy
  has_many :content
  has_many :comment_user_reactions, through: :comment

  validates_presence_of :circle_id
  validates_presence_of :author_id
end
