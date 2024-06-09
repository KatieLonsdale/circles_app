class CommentUserReaction < ApplicationRecord
  belongs_to :comment

  validates_presence_of :comment_id, :user_id, :reaction_id
end
