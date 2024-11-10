class Content < ApplicationRecord
  belongs_to :post

  validates_presence_of :post_id
  has_many_attached :files
end
