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
  
  describe '.send_post_notification' do
    let(:circle) { create(:circle) }
    let(:post_author) { create(:user) }
    let(:post) { create(:post, circle: circle, author_id: post_author.id) }
    let(:members) { create_list(:circle_member, 3, circle: circle) }
    
    before do
      # Set up a circle with members
      members.each do |member|
        member.user.update(notification_frequency: 'live', notifications_token: 'valid_token')
      end
      
      # Mock FCM client to prevent actual API calls
      allow(FCM_CLIENT).to receive(:send).and_return(
        "success" => 3,
        "failure" => 0
      )
    end

    it 'creates database notifications for all circle members except the author' do
      expect {
        NotificationService.send_post_notification(post)
      }.to change(Notification, :count).by(members.count)
      
      members.each do |member|
        expect(member.user.notifications.count).to eq(1)
        notification = member.user.notifications.first
        expect(notification.message).to include(post_author.display_name)
        expect(notification.message).to include(circle.name)
        expect(notification.notifiable).to eq(post)
        expect(notification.action).to eq('post_created')
        expect(notification.circle_name).to eq(circle.name)
      end
      
      # Author should not receive a notification
      expect(post_author.notifications.count).to eq(0)
    end

    it 'sends FCM notifications to circle members with live notifications enabled' do
      # Get tokens of the users with live notifications
      live_tokens = members.map { |m| m.user.notifications_token }
      
      expect(FCM_CLIENT).to receive(:send).with(
        live_tokens,
        {
          notification: {
            title: "New Post in #{circle.name}",
            body: "#{post_author.display_name} created a new post in #{circle.name}!"
          },
          data: {
            post_id: post.id.to_s,
            circle_id: circle.id.to_s,
            type: 'post'
          }
        }
      )

      NotificationService.send_post_notification(post)
    end

    it 'does not send FCM notifications to users with non-live notification preference' do
      members.each do |member|
        member.user.update(notification_frequency: 'daily')
      end
      
      # Still create DB notifications for everyone
      expect {
        NotificationService.send_post_notification(post)
      }.to change(Notification, :count).by(members.count)
      
      # But don't send FCM notifications
      expect(FCM_CLIENT).not_to receive(:send)
      
      NotificationService.send_post_notification(post)
    end

    it 'does not send FCM notifications if users have no firebase token' do
      members.each do |member|
        member.user.update(notifications_token: nil)
      end
      
      # Still create DB notifications for everyone
      expect {
        NotificationService.send_post_notification(post)
      }.to change(Notification, :count).by(members.count)
      
      # But don't send FCM notifications
      expect(FCM_CLIENT).not_to receive(:send)
      
      NotificationService.send_post_notification(post)
    end

    it 'logs error when FCM call fails' do
      allow(FCM_CLIENT).to receive(:send).and_raise(StandardError.new("FCM Error"))
      allow(Rails.logger).to receive(:error)

      expect(Rails.logger).to receive(:error).with("Failed to send notification: FCM Error")

      NotificationService.send_post_notification(post)
    end
  end
end 