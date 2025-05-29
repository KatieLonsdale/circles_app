class Api::V0::Users::CirclesController < ApplicationController
  before_action :get_user

  def index
    all_circles = @user.get_all_circles
    render json: CircleSerializer.new(all_circles)
  end

  def create
    circle = Circle.create!(circle_params)
    CircleMember.create!(circle_id: circle.id, user_id: @user.id)
    render json: CircleSerializer.new(circle), status: :created
  end

  def destroy
    circle = Circle.find(params[:id])
    if @user.id != circle.user_id || !@user.authenticate(params[:password])
      render json: {"errors": "Unauthorized"}, status: :unauthorized
    else
      circle.destroy!
    end
  end

  private
  def get_user
    @user = User.find(params[:user_id])
  end

  def circle_params
    params.permit(:user_id, :name, :description)
  end
end