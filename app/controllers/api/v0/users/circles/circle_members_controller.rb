class Api::V0::Users::Circles::CircleMembersController < ApplicationController
  before_action :find_circle, :find_user, :authorize_owner

  def create
    circle_member = CircleMember.create!(circle_member_params)
    render json: CircleMemberSerializer.new(circle_member), status: :created
  end

  private

  def circle_member_params
    params.permit(:circle_id).merge(user_id: params[:new_member_id])
  end

  def find_circle
    @circle = Circle.find(params[:circle_id])
  end

  def find_user
    @user = User.find(params[:user_id])
  end

  def authorize_owner
    unauthorized_user if !@circle.owner?(@user.id)
  end
end