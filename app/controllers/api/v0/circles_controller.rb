class Api::V0::CirclesController < ApplicationController
  def index
    render json: CircleSerializer.new(Circle.all)
  end

  def show
    circle = Circle.find(params[:id])
    render json: CircleSerializer.new(circle)
  end
end