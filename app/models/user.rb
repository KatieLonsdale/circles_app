class User < ApplicationRecord
  has_many :circles, dependent: :destroy

  enum notification_frequency: { live: 0, hourly: 1, daily: 2 }

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_secure_password
  validates :email, 
            presence: true, 
            uniqueness: { case_sensitive: false},
            format: { with: EMAIL_REGEX, message: "must be a valid email address" }
  validates_presence_of :password
  validates_presence_of :display_name
end
