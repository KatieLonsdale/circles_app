class PostUserReaction < ApplicationRecord
  belongs_to :post

  validates_presence_of :post_id, :user_id, :reaction_id
end
