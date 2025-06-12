class Api::V0::FriendshipsController < ApplicationController
  before_action :find_user, only: [:index, :pending, :create, :accept, :reject, :destroy]
  
  # GET /api/v0/users/:user_id/friendships
  def index
    friendships = @user.all_friends
    render json: UserSerializer.new(friendships)
  end
  
  # GET /api/v0/users/:user_id/friendships/pending
  def pending
    pending_requests = @user.pending_inverse_friends
    render json: UserSerializer.new(pending_requests)
  end
  
  # POST /api/v0/users/:user_id/friendships
  def create
    friend = User.find(params[:friend_id])
    friendship = @user.friend_request(friend)
    
    if friendship.persisted?
      render json: FriendshipSerializer.new(friendship), status: :created
    else
      render json: { errors: friendship.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # PATCH /api/v0/users/:user_id/friendships/:id/accept
  def accept
    friend = User.find(params[:id])
    @user.accept_friend_request(friend)
    
    friendship = Friendship.find_by(user_id: params[:id], friend_id: @user.id)
    if friendship && friendship.accepted?
      render json: FriendshipSerializer.new(friendship)
    else
      render json: { errors: ["Unable to accept friend request"] }, status: :unprocessable_entity
    end
  end
  
  # PATCH /api/v0/users/:user_id/friendships/:id/reject
  def reject
    friend = User.find(params[:id])
    @user.reject_friend_request(friend)
    
    friendship = Friendship.find_by(user_id: params[:id], friend_id: @user.id)
    if friendship && friendship.rejected?
      render json: FriendshipSerializer.new(friendship)
    else
      render json: { errors: ["Unable to reject friend request"] }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v0/users/:user_id/friendships/:id
  def destroy
    friend = User.find(params[:id])
    friendship = Friendship.find_by(
      "(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)",
      @user.id, friend.id, friend.id, @user.id
    )
    
    if friendship
      @user.remove_friend(friend)
      head :no_content
    else
      render json: { errors: ["Friendship does not exist"] }, status: :unprocessable_entity
    end
  end
  
  private
  
  def find_user
    @user = User.find(params[:user_id])
  end
end 