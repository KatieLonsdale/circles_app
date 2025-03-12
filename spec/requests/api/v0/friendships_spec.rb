require 'rails_helper'

RSpec.describe "Api::V0::Friendships", type: :request do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{token_for(user)}" } }

  describe "GET /api/v0/users/:user_id/friendships" do
    context "when user has friends" do
      before do
        create(:friendship, user: user, friend: friend, status: :accepted)
      end

      it "returns a list of friends" do
        get "/api/v0/users/#{user.id}/friendships", headers: headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['attributes']['display_name']).to eq(friend.display_name)
      end
    end

    context "when user has no friends" do
      it "returns an empty list" do
        get "/api/v0/users/#{user.id}/friendships", headers: headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(0)
      end
    end
  end

  describe "GET /api/v0/users/:user_id/friendships/pending" do
    context "when user has pending friend requests" do
      before do
        create(:friendship, user: friend, friend: user, status: :pending)
      end

      it "returns a list of pending friend requests" do
        get "/api/v0/users/#{user.id}/friendships/pending", headers: headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['attributes']['display_name']).to eq(friend.display_name)
      end
    end

    context "when user has no pending friend requests" do
      before do
        create(:friendship, user: user, friend: friend, status: :accepted)
      end
      it "returns an empty list" do
        get "/api/v0/users/#{user.id}/friendships/pending", headers: headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(0)
      end
    end
  end

  describe "POST /api/v0/users/:user_id/friendships" do
    context "when sending a valid friend request" do
      it "creates a new pending friendship" do
        expect {
          post "/api/v0/users/#{user.id}/friendships", 
               params: { friend_id: friend.id }, 
               headers: headers
        }.to change(Friendship, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['status']).to eq('pending')
        expect(json['data']['attributes']['friend']['id']).to eq(friend.id)
      end
    end

    context "when sending a friend request to self" do
      it "returns an error" do
        expect {
          post "/api/v0/users/#{user.id}/friendships", 
               params: { friend_id: user.id }, 
               headers: headers
        }.not_to change(Friendship, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Friend can't be the same as user")
      end
    end

    context "when sending a duplicate friend request" do
      before do
        create(:friendship, user: user, friend: friend)
      end

      it "returns an error" do
        expect {
          post "/api/v0/users/#{user.id}/friendships", 
               params: { friend_id: friend.id }, 
               headers: headers
        }.not_to change(Friendship, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("User friendship already exists")
      end
    end
  end

  describe "PATCH /api/v0/users/:user_id/friendships/:id/accept" do
    context "when accepting a valid friend request" do
      before do
        create(:friendship, user: friend, friend: user, status: :pending)
      end

      it "updates the friendship status to accepted" do
        patch "/api/v0/users/#{user.id}/friendships/#{friend.id}/accept", headers: headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['status']).to eq('accepted')
        
        friendship = Friendship.find_by(user: friend, friend: user)
        expect(friendship.status).to eq('accepted')
      end
    end

    context "when accepting a non-existent friend request" do
      it "returns an error" do
        patch "/api/v0/users/#{user.id}/friendships/#{friend.id}/accept", headers: headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Unable to accept friend request")
      end
    end
  end

  describe "PATCH /api/v0/users/:user_id/friendships/:id/reject" do
    context "when rejecting a valid friend request" do
      before do
        create(:friendship, user: friend, friend: user, status: :pending)
      end

      it "updates the friendship status to rejected" do
        patch "/api/v0/users/#{user.id}/friendships/#{friend.id}/reject", headers: headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['status']).to eq('rejected')
        
        friendship = Friendship.find_by(user: friend, friend: user)
        expect(friendship.status).to eq('rejected')
      end
    end

    context "when rejecting a non-existent friend request" do
      it "returns an error" do
        patch "/api/v0/users/#{user.id}/friendships/#{friend.id}/reject", headers: headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Unable to reject friend request")
      end
    end
  end

  describe "DELETE /api/v0/users/:user_id/friendships/:id" do
    context "when removing an existing friend" do
      before do
        create(:friendship, user: user, friend: friend, status: :accepted)
      end

      it "removes the friendship" do
        expect {
          delete "/api/v0/users/#{user.id}/friendships/#{friend.id}", headers: headers
        }.to change(Friendship, :count).by(-1)
        
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when removing a non-existent friend" do
      it "returns an unprocessable entity error" do
        delete "/api/v0/users/#{user.id}/friendships/#{friend.id}", headers: headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Friendship does not exist")
      end
    end
  end

  # Helper method to generate a token for authentication
  def token_for(user)
    # Use a simple string for testing instead of Rails.application.credentials.secret_key_base
    JWT.encode({ user_id: user.id }, 'test_secret_key')
  end
end 