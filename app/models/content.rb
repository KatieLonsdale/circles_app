class Content < ApplicationRecord
  belongs_to :post

  validates_presence_of :post_id
end
