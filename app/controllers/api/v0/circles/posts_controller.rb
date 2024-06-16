class Api::V0::Circles::PostsController < ApplicationController
  before_action :get_circle
  before_action :authenticate_user

  def index
    posts = @circle.posts
    render json: PostSerializer.new(posts)
  end

  def create
    post = @circle.posts.create!(post_params)
    content = Content.create!(content_params(post.id))
    render json: PostSerializer.new(post), status: :created
  end

  def update
    post = @circle.posts.find(params[:id])
    post.update!(post_params)
    render json: PostSerializer.new(post)
  end

  def destroy
    post = @circle.posts.find(params[:id])
    if post.owner_or_author?(params[:user_id].to_i)
      post.destroy!
      render json: {}, status: :no_content
    else
      unauthorized_user
    end
  end

  private

  def get_circle
    @circle = Circle.find(params[:circle_id])
  end

  def post_params
    params.permit(:author_id, :caption).merge(author_id: params[:user_id])
  end

  def content_params(post_id)
    params.require(:contents).permit(:video_url, :image_url, :post_id).merge(post_id: post_id)
  end

  def authenticate_user
    unauthorized_user if !@circle.verify_member(params[:user_id].to_i)
  end
end