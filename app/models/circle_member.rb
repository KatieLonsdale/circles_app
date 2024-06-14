class CircleMember < ApplicationRecord
  belongs_to :user
  belongs_to :circle

  validates_presence_of :circle_id
  validates_presence_of :user_id
end