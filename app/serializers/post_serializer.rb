class PostSerializer
  include JSONAPI::Serializer
  attributes :id, 
             :author_id, 
             :caption, 
             :created_at, 
             :updated_at,
             :circle_id

  attribute :author_display_name do |object|
    object.author_display_name
  end

  attribute :circle_name do |object|
    object.circle.name
  end

  attribute :contents do |post|
    ContentSerializer.new(post.content)
  end

  attribute :comments do |post|
    CommentSerializer.new(post.comments)
  end
end