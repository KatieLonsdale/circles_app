class Api::V0::Users::Circles::Posts::CommentsController < ApplicationController
  before_action :get_post, only: [:create, :show, :update, :destroy]
  before_action :get_circle
  before_action :authenticate_user
  before_action :authenticate_author, only: [:update]

  def create
    comment = Comment.create!(comment_params)
    render json: CommentSerializer.new(comment), status: :created
  end

  def update
    comment = Comment.find(params[:id])
    comment.update!(update_comment_params)
    render json: CommentSerializer.new(comment), status: :ok
  end

  private
  
  def comment_params
    params.permit(:comment_text, :parent_comment_id, :author_id, :post_id).
      merge(author_id: params[:user_id], post_id: @post.id)
  end

  def update_comment_params
    params.permit(:comment_text)
  end

  def get_post
    @post = Post.find(params[:post_id])
  end

  def get_circle
    @circle = Circle.find(params[:circle_id])
  end

  def authenticate_user
    unauthorized_user if !@circle.verify_member(params[:user_id].to_i)
  end

  def authenticate_author
    unauthorized_user if @post.author_id != params[:user_id].to_i
  end
end