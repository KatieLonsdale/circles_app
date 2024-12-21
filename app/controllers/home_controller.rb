class HomeController < ApplicationController
  skip_before_action :authorize_request, only: [:index]

  def index
    render json: {"Status": "Up"}, status: :ok
  end
end
