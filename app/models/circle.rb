class Circle < ApplicationRecord
  belongs_to :user
  has_many :posts, dependent: :destroy
  has_many :comments, through: :posts
  has_many :post_user_reactions, through: :posts
  has_many :content, through: :posts

  validates_presence_of :name
  validates_presence_of :user_id
  validates_presence_of :description

end
