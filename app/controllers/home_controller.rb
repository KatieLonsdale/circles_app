class HomeController < ApplicationController
  def index
    render json: {"Status": "Up"}, status: :ok
  end
end
