class User < ApplicationRecord
  has_many :circles, dependent: :destroy

  enum notification_frequency: { live: 0, hourly: 1, daily: 2 }

  validates :email, 
            presence: true, 
            uniqueness: { case_sensitive: false}
  validates_presence_of :password
  validates_presence_of :display_name

  has_secure_password
end
