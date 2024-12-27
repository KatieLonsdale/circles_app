class Api::V0::SessionsController < ApplicationController
  skip_before_action :authorize_request, only: [:create]
  
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      puts(user)
      token = JsonWebTokenService.encode(user_id: user.id)
      render json: { 
        token: token,
        user: UserSerializer.new(user)
        }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
end

