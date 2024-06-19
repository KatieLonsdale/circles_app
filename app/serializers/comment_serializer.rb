class CommentSerializer
  include JSONAPI::Serializer
  attributes :id,
             :author_id, 
             :parent_comment_id, 
             :post_id,
             :comment_text, 
             :created_at, 
             :updated_at
end