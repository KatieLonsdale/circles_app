class CircleMemberSerializer
  include JSONAPI::Serializer
  attributes :id, :user_id, :circle_id
end