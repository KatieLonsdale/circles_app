class PostSerializer
  include JSONAPI::Serializer
  attributes :id, 
             :author_id, 
             :caption, 
             :created_at, 
             :updated_at
  
  attribute :contents do |post|
    ContentSerializer.new(post.content)
  end

  attribute :comments do |post|
    CommentSerializer.new(post.comments)
  end
end