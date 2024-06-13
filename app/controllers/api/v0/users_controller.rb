class Api::V0::UsersController < ApplicationController
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

  private

  def user_params
    params.permit(
            :email, 
            :password, 
            :password_confirmation, 
            :display_name,
            :notification_frequency)
  end
end