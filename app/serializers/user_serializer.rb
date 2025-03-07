class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :display_name, :notification_frequency, :last_tou_acceptance
  
  attribute :friends_count do |user|
    user.all_friends.count
  end
  
  attribute :pending_friends_count do |user|
    user.all_pending_friends.count
  end
end