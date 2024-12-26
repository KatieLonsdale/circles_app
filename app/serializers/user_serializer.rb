class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :display_name, :notification_frequency, :last_tou_acceptance
end