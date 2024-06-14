class Api::V0::Users::CirclesController < ApplicationController
  before_action :get_user
  def index
    all_circles = @user.get_all_circles
    render json: CircleSerializer.new(all_circles)
  end

  def show
    circle = Circle.find(params[:id])
    render json: CircleSerializer.new(circle)
  end

  private
  def get_user
    @user = User.find(params[:user_id])
  end

  def user_params
    params.permit(:user_id, :name, :description)
  end
end