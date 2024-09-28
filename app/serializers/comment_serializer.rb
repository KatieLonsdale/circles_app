class CommentSerializer
  include JSONAPI::Serializer
  attributes :id,
             :author_id, 
             :parent_comment_id, 
             :post_id,
             :comment_text, 
             :created_at, 
             :updated_at

  attribute :author_display_name do |object|
    object.author_display_name
  end
end