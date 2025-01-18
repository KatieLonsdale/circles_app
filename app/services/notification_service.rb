class NotificationService
  def self.send_comment_notification(comment)
    post = comment.post
    author = User.find(post.author_id)
    
    return if author.id == comment.author_id # Don't notify if author comments on their own post
    return unless author.notification_frequency == 'live' # Only send if user wants live notifications
    return if author.notifications_token.blank?
    
    options = {
      notification: {
        title: "New Comment on Your Post",
        body: "#{comment.author_display_name} commented: #{comment.comment_text.truncate(50)}"
      },
      data: {
        post_id: post.id.to_s,
        circle_id: post.circle_id.to_s,
        comment_id: comment.id.to_s,
        type: 'comment'
      }
    }

    begin
      response = FCM_CLIENT.send([author.notifications_token], options)
      Rails.logger.info "FCM Response: #{response}"
    rescue => e
      Rails.logger.error "Failed to send notification: #{e.message}"
    end
  end
end 