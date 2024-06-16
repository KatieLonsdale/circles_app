class Api::V0::Circles::PostsController < ApplicationController
  before_action :get_circle
  before_action :authenticate_user

  def index
    posts = @circle.posts
    render json: PostSerializer.new(posts)
  end

  private

  def get_circle
    @circle = Circle.find(params[:circle_id])
  end

  def circle_params
    params.permit(:author_id, :caption, :contents)
  end

  def authenticate_user
    unauthorized_user if !@circle.verify_member(params[:user_id])
  end
end