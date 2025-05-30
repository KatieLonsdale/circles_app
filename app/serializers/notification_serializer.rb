class NotificationSerializer
  include JSONAPI::Serializer
  
  attributes :id, :message, :read, :action, :created_at, :updated_at, :circle_id
  
  attribute :circle_name do |notification|
    notification.circle_name
  end
  
  attribute :notifiable_type do |notification|
    notification.notifiable_type.downcase
  end
  
  attribute :notifiable_id do |notification|
    notification.notifiable_id
  end

  # the frontend will need the post id for any post related notifications
  attribute :post_id do |notification|
    if notification.notifiable_type.downcase == 'post'
      notification.notifiable_id
    elsif notification.notifiable_type.downcase == 'comment'
      print(notification)
      notification.notifiable.post_id
    end
  end
end
