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
end
