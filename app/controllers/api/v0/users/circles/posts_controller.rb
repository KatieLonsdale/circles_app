class Api::V0::Users::Circles::PostsController < ApplicationController
  before_action :get_circle
  before_action :authenticate_user

  def index
    posts = @circle.posts
    render json: PostSerializer.new(posts)
  end

  def create
    post = @circle.posts.create!(post_params)
    post_id = post.id
    content_id = Content.create!(content_params(post.id)).id
    if params.dig(:post,:contents,:video)
      upload_file(params.dig(:post,:contents,:video), "#{@circle.id}_#{post_id}_videos", content_id)
    elsif params.dig(:post,:contents,:image)
      upload_file(params.dig(:post,:contents,:image), "#{@circle.id}_#{post_id}_images", content_id)
    end
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
    params.require(:post).permit(:caption, :circle_id).merge(author_id: params[:user_id])
  end

  def content_params(post_id)
    params[:post].require(:contents).permit(:post_id, :video, :image).merge(post_id: post_id)
  end

  def authenticate_user
    unauthorized_user if !@circle.verify_member(params[:user_id].to_i)
  end

  def upload_file(file, folder, content_id)
    ImageUploadService.upload(file, folder, content_id)
  end
end