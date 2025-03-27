class Api::V0::Users::NotificationsController < ApplicationController
  before_action :find_user
  before_action :find_notification, only: [:show, :update, :destroy]

  def index
    notifications = @user.notifications
    
    # Filter by read status if the param is provided
    if params[:read].present?
      read_status = ActiveModel::Type::Boolean.new.cast(params[:read])
      notifications = read_status ? notifications.read : notifications.unread
    end
    
    # Always sort by newest first
    notifications = notifications.newest_first
    
    render json: NotificationSerializer.new(notifications)
  end

  def show
    render json: NotificationSerializer.new(@notification)
  end

  def update
    @notification.mark_as_read!
    render json: NotificationSerializer.new(@notification)
  end
  
  def destroy
    @notification.destroy!
    render json: {}, status: :no_content
  end
  
  def mark_all_read
    @user.mark_all_notifications_as_read!
    render json: { success: true, message: "All notifications marked as read" }, status: :ok
  end
  
  private
  
  def find_user
    @user = User.find(params[:user_id])
  end
  
  def find_notification
    @notification = @user.notifications.find(params[:id])
  end
end
