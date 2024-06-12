class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :display_name, :notification_frequency
end