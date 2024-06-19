class Api::V0::Users::Circles::Posts::CommentsController < ApplicationController
  before_action :get_post, only: [:index, :create, :show, :update, :destroy]
  before_action :get_circle
  before_action :get_comment, only: [:show, :update, :destroy]
  before_action :authenticate_user

  def index
    comments = @post.comments
    render json: CommentSerializer.new(comments), status: :ok
  end

  def show
    comment = Comment.find(params[:id])
    render json: CommentSerializer.new(comment), status: :ok
  end

  def create
    comment = Comment.create!(comment_params)
    render json: CommentSerializer.new(comment), status: :created
  end

  def update
    if authenticate_author
      @comment.update!(update_comment_params)
      render json: CommentSerializer.new(@comment), status: :ok
    else 
      unauthorized_user
    end
  end

  def destroy
    if authenticate_author || authenticate_owner
      @comment.destroy!
      render json: {}, status: :no_content
    else
      unauthorized_user
    end
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

  def get_comment
    @comment = Comment.find(params[:id])
  end

  def authenticate_user
    unauthorized_user if !@circle.verify_member(params[:user_id].to_i)
  end

  def authenticate_author
    @post.author_id == params[:user_id].to_i
  end

  def authenticate_owner
    @circle.user_id == params[:user_id].to_i
  end
end