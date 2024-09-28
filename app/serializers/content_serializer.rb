class ContentSerializer
  include JSONAPI::Serializer

  attributes :id, :video_url

  attribute :presigned_image_url do |object|
    ImageUploadService.new.create_presigned_url(object.image_url) if object.image_url
  end
end