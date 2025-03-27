class NotificationService
  def self.send_comment_notification(comment)
    post = comment.post
    author = User.find(post.author_id)
    return if author.id == comment.author_id # Don't notify if author comments on their own post
    return unless author.notification_frequency == 'live' # Only send if user wants live notifications
    return if author.notifications_token.blank?
    
    # Create notification message
    message = "#{comment.author_display_name} commented: #{comment.comment_text.truncate(50)}"
    
    # Create DB notification record
    Notification.create!(
      user: author,
      notifiable: comment,
      message: message,
      action: 'comment_created',
      circle_id: post.circle_id # Use circle_id directly instead of circle association
    )
    
    options = {
      notification: {
        title: "New Comment on Your Post",
        body: message
      },
      data: {
        post_id: post.id.to_s,
        circle_id: post.circle_id.to_s,
        comment_id: comment.id.to_s,
        type: 'comment'
      }
    }

    begin
      # Using send_notification_v1 method with the proper format
      message = {
        token: author.notifications_token,
        notification: options[:notification],
        data: options[:data]
      }
      response = FCM_CLIENT.send_notification_v1(message)
      Rails.logger.info "FCM Response: #{response}"
      Rails.logger.info "FCM Response Status Code: #{response.status_code}" if response.respond_to?(:status_code)
    rescue => e
      Rails.logger.error "Failed to send notification: #{e.message}"
    end
  end

  def self.send_post_notification(post)
    circle = post.circle
    author = User.find(post.author_id)
    
    # Get all members of the circle (excluding the post author)
    members = circle.circle_members.includes(:user).where.not(user_id: author.id)
    
    # Format the notification message
    message = "#{author.display_name} created a new post in #{circle.name}!"
    
    # Create DB notifications for all members
    members.each do |member|
      Notification.create!(
        user: member.user,
        notifiable: post,
        message: message,
        action: 'post_created',
        circle_id: circle.id
      )
    end
    
    # Send push notifications to members with live notification preference and a valid token
    live_users = members.select { |m| m.user.notification_frequency == 'live' && m.user.notifications_token.present? }
    tokens = live_users.map { |m| m.user.notifications_token }
    
    return if tokens.empty?
    
    options = {
      notification: {
        title: "New Post in #{circle.name}",
        body: message
      },
      data: {
        post_id: post.id.to_s,
        circle_id: circle.id.to_s,
        type: 'post'
      }
    }

    begin
      # We can only send to one token at a time with send_notification_v1
      # So loop through each token and send individually
      responses = []
      tokens.each do |token|
        message = {
          token: token,
          notification: options[:notification],
          data: options[:data]
        }
        response = FCM_CLIENT.send_notification_v1(message)
        responses << response
      end
      puts "FCM Response: #{responses}"
    rescue => e
      Rails.logger.error "Failed to send notification: #{e.message}"
    end
  end

  def self.send_friend_request_notification(friendship)
    requester = friendship.user
    requestee = friendship.friend
    
    # Don't send if user has disabled notifications
    return unless requestee.notification_frequency == 'live'
    return if requestee.notifications_token.blank?
    
    # Create notification message
    message = "#{requester.display_name} sent you a friend request"
    
    # Create DB notification record - note that circle_id is nil
    Notification.create!(
      user: requestee,
      notifiable: friendship,
      message: message,
      action: 'friend_request',
      circle_id: nil
    )
    
    # Send push notification
    options = {
      notification: {
        title: "New Friend Request",
        body: message
      },
      data: {
        friendship_id: friendship.id.to_s,
        requester_id: requester.id.to_s,
        type: 'friend_request'
      }
    }

    begin
      # Using send_notification_v1 method with the proper format
      fcm_message = {
        token: requestee.notifications_token,
        notification: options[:notification],
        data: options[:data]
      }
      response = FCM_CLIENT.send_notification_v1(fcm_message)
      Rails.logger.info "FCM Response: #{response}"
    rescue => e
      Rails.logger.error "Failed to send notification: #{e.message}"
    end
  end
end 