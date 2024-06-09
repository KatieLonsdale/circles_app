class Comment < ApplicationRecord
  belongs_to :post
  has_many :comment_user_reactions, dependent: :destroy

  validates_presence_of :post_id
  validates_presence_of :author_id
  validates_presence_of :comment_text
end
