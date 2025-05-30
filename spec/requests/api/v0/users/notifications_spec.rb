require 'rails_helper'

RSpec.describe "Api::V0::Users::Notifications", type: :request do
  describe "GET /users/:user_id/notifications" do
    before(:all) do
      User.destroy_all
    end

    it "returns all notifications for a user" do
      user = create(:user)
      circle = create(:circle)
      comment = create(:comment, post: create(:post, circle: circle))
      create_list(:notification, 2, user: user, circle: circle, notifiable: comment)
      create_list(:notification, 1, user: user, circle: circle, notifiable: create(:post, circle: circle))
      
      get "/api/v0/users/#{user.id}/notifications"
      
      expect(response).to have_http_status(:ok)
      
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(data.count).to eq(3)
      expect(data.first[:attributes]).to include(:message, :read, :action)
    end
    
    it "returns notifications ordered by newest first" do
      user = create(:user)
      circle = create(:circle)
      old_notification = create(:notification, user: user, circle: circle, created_at: 2.days.ago)
      middle_notification = create(:notification, user: user, circle: circle, created_at: 1.day.ago)
      new_notification = create(:notification, user: user, circle: circle, created_at: 1.hour.ago)
      
      get "/api/v0/users/#{user.id}/notifications"
      
      expect(response).to have_http_status(:ok)
      
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(data.count).to eq(3)
      expect(data[0][:id].to_i).to eq(new_notification.id)
      expect(data[1][:id].to_i).to eq(middle_notification.id)
      expect(data[2][:id].to_i).to eq(old_notification.id)
    end

    it "returns deleted string for comment's post_id if comment's post parent is deleted" do
      user = create(:user)
      circle = create(:circle)
      post = create(:post, circle: circle)
      post_2 = create(:post, circle: circle)
      comment = create(:comment, post: post)
      create(:notification, user: user, circle: circle, notifiable: post)
      create(:notification, user: user, circle: circle, notifiable: comment)
      create(:notification, user: user, circle: circle, notifiable: post_2)
      post.destroy

      get "/api/v0/users/#{user.id}/notifications"
      
      expect(response).to have_http_status(:ok)
      
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(data.count).to eq(2)
      expect(data[0][:attributes][:post_id]).to eq(post_2.id)
      expect(data[1][:attributes][:post_id]).to eq('deleted')
    end
    
    it "filters notifications by read status when read=true" do
      user = create(:user)
      circle = create(:circle)
      read_notifications = create_list(:notification, 2, user: user, circle: circle, read: true)
      unread_notifications = create_list(:notification, 3, user: user, circle: circle, read: false)
      
      get "/api/v0/users/#{user.id}/notifications?read=true"
      
      expect(response).to have_http_status(:ok)
      
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(data.count).to eq(2)
      data.each do |notification|
        expect(notification[:attributes][:read]).to eq(true)
      end
    end
    
    it "filters notifications by read status when read=false" do
      user = create(:user)
      circle = create(:circle)
      read_notifications = create_list(:notification, 2, user: user, circle: circle, read: true)
      unread_notifications = create_list(:notification, 3, user: user, circle: circle, read: false)
      
      get "/api/v0/users/#{user.id}/notifications?read=false"
      
      expect(response).to have_http_status(:ok)
      
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(data.count).to eq(3)
      data.each do |notification|
        expect(notification[:attributes][:read]).to eq(false)
      end
    end
  end
  
  describe "GET /users/:user_id/notifications/:id" do
    it "returns a specific notification" do
      user = create(:user)
      circle = create(:circle)
      notification = create(:notification, user: user, circle: circle)
      
      get "/api/v0/users/#{user.id}/notifications/#{notification.id}"
      
      expect(response).to have_http_status(:ok)
      
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(data[:id].to_i).to eq(notification.id)
      expect(data[:attributes][:message]).to eq(notification.message)
    end
    
    it "returns 404 if notification doesn't exist" do
      user = create(:user)
      
      get "/api/v0/users/#{user.id}/notifications/999999"
      
      expect(response).to have_http_status(:not_found)
    end
  end
  
  describe "PATCH /users/:user_id/notifications/:id" do
    it "marks a notification as read" do
      user = create(:user)
      circle = create(:circle)
      notification = create(:notification, user: user, circle: circle, read: false)
      
      expect(notification.read).to eq(false)
      
      patch "/api/v0/users/#{user.id}/notifications/#{notification.id}"
      
      expect(response).to have_http_status(:ok)
      
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(data[:attributes][:read]).to eq(true)
      
      # Verify the notification was updated in the database
      notification.reload
      expect(notification.read).to eq(true)
    end
  end
  
  describe "DELETE /users/:user_id/notifications/:id" do
    it "deletes a notification" do
      user = create(:user)
      circle = create(:circle)
      notification = create(:notification, user: user, circle: circle)
      
      expect {
        delete "/api/v0/users/#{user.id}/notifications/#{notification.id}"
      }.to change(Notification, :count).by(-1)
      
      expect(response).to have_http_status(:no_content)
    end
  end
  
  describe "POST /users/:user_id/notifications/mark_all_read" do
    it "marks all unread notifications as read" do
      user = create(:user)
      circle = create(:circle)
      
      # Create a mix of read and unread notifications
      read_notification = create(:notification, user: user, circle: circle, read: true)
      unread_notifications = create_list(:notification, 3, user: user, circle: circle, read: false)
      
      # Verify initial state
      expect(user.notifications.unread.count).to eq(3)
      expect(user.notifications.read.count).to eq(1)
      
      # Mark all as read
      post "/api/v0/users/#{user.id}/notifications/mark_all_read"
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body, symbolize_names: true)[:success]).to eq(true)
      
      # Verify all notifications are now read
      expect(user.notifications.unread.count).to eq(0)
      expect(user.notifications.read.count).to eq(4)
    end
  end
end
