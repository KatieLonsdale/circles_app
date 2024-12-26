module Authorize
  extend ActiveSupport::Concern

  included do
    before_action :authorize_request
  end

  private

  def authorize_request
    header = request.headers['Authorization']
    if header.nil?
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end
    token = header.split(' ').last
    decoded = JsonWebTokenService.decode(token)
    if decoded.nil?
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
