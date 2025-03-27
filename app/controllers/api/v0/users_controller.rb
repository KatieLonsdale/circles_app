class Api::V0::UsersController < ApplicationController
  before_action :find_user, only: [:show, :update, :destroy, :newsfeed]
  skip_before_action :authorize_request, only: [:create, :authenticate, :search]

  def index
    render json: UserSerializer.new(User.all)
  end

  def show
    user = User.find(params[:id])
    render json: UserSerializer.new(user)
  end

  def create
    user = User.create!(user_params)
    render json: UserSerializer.new(user), status: :created
  end

  def update
    user = User.find(params[:id])
    user.update!(user_params)
    render json: UserSerializer.new(user), status: :no_content
  end

  def destroy
    user = User.find(params[:id])
    user.destroy!
  end

  def authenticate
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      render json: UserSerializer.new(user)
    else
      render json: {"errors": "Invalid email or password"}, status: :unauthorized
    end
  end

  def newsfeed
    newsfeed = @user.get_newsfeed
    render json: PostSerializer.new(newsfeed)
  end

  def search
    users = User.search(params[:query]) || []
    render json: UserSerializer.new(users)
  end

  private

  def user_params
    params.permit(
            :email, 
            :password, 
            :password_confirmation, 
            :display_name,
            :notification_frequency,
            :last_tou_acceptance,
            :notifications_token
            )
  end

  def find_user
    @user = User.find(params[:id] || params[:user_id])
  end
end