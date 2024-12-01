class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from JWT::DecodeError, with: :unauthorized_user

  private

  def record_not_found(exception)
    render json: { "errors": exception.message }, status: :not_found
  end

  def record_invalid(exception)
    render json: { "errors": exception.message }, status: :unprocessable_entity
  end

  def unauthorized_user
    render json: { "errors": "Unauthorized" }, status: :unauthorized
  end
end
