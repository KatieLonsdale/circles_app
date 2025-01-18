require 'rails_helper'

RSpec.describe NotificationService do
  describe '.send_comment_notification' do
    let(:circle) { create(:circle) }
    let(:post_author) { create(:user, notification_frequency: 'live', notifications_token: 'valid_token_123') }
    let(:commenter) { create(:user) }
    let(:post) { create(:post, circle: circle, author_id: post_author.id) }
    let(:comment) { create(:comment, post: post, author_id: commenter.id, comment_text: "This is a test comment") }
    
    before do
      # Mock FCM client to prevent actual API calls
      allow(FCM_CLIENT).to receive(:send).and_return(
        "success" => 1,
        "failure" => 0
      )
    end

    it 'sends notification when all conditions are met' do
      expect(FCM_CLIENT).to receive(:send).with(
        [post_author.notifications_token],
        {
          notification: {
            title: "New Comment on Your Post",
            body: "#{commenter.display_name} commented: #{comment.comment_text}"
          },
          data: {
            post_id: post.id.to_s,
            circle_id: post.circle_id.to_s,
            comment_id: comment.id.to_s,
            type: 'comment'
          }
        }
      )

      NotificationService.send_comment_notification(comment)
    end

    it 'does not send notification if post author comments on their own post' do
      comment.update(author_id: post_author.id)
      
      expect(FCM_CLIENT).not_to receive(:send)
      
      NotificationService.send_comment_notification(comment)
    end

    it 'does not send notification if notifications are not live' do
      post_author.update(notification_frequency: 'daily')
      
      expect(FCM_CLIENT).not_to receive(:send)
      
      NotificationService.send_comment_notification(comment)
    end

    it 'does not send notification if author has no firebase token' do
      post_author.update(notifications_token: nil)
      
      expect(FCM_CLIENT).not_to receive(:send)
      
      NotificationService.send_comment_notification(comment)
    end

    it 'logs error when FCM call fails' do
      allow(FCM_CLIENT).to receive(:send).and_raise(StandardError.new("FCM Error"))
      allow(Rails.logger).to receive(:error)

      expect(Rails.logger).to receive(:error).with("Failed to send notification: FCM Error")

      NotificationService.send_comment_notification(comment)
    end
  end
end 