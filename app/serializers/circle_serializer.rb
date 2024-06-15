class CircleSerializer
  include JSONAPI::Serializer
  attributes :id, :user_id, :name, :description
end