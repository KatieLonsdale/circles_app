class FriendshipSerializer
  include JSONAPI::Serializer
  attributes :id, :status, :created_at, :updated_at
  
  attribute :friend do |friendship|
    {
      id: friendship.friend.id,
      #todo: do we need email? 3/7
      email: friendship.friend.email,
      display_name: friendship.friend.display_name
    }
  end
  
  attribute :user do |friendship|
    {
      id: friendship.user.id,
      email: friendship.user.email,
      display_name: friendship.user.display_name
    }
  end
end 