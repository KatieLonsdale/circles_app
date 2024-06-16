class ContentSerializer
  include JSONAPI::Serializer
  attributes :id, :video_url, :image_url
end