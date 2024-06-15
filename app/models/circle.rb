class Circle < ApplicationRecord
  belongs_to :user
  has_many :posts, dependent: :destroy
  has_many :comments, through: :posts
  has_many :post_user_reactions, through: :posts
  has_many :content, through: :posts
  has_many :circle_members, dependent: :destroy

  validates_presence_of :name
  validates_presence_of :user_id
  validates_presence_of :description

  def add_member(user_id)
    new_member = {"id" => user_id}
    updated_members = JSON.parse(members) << new_member
    self.members = updated_members.to_json
  end
end
