require 'rails_helper'

RSpec.describe 'Comments API', type: :request do
  describe 'get comments' do
    it 'gets all comments for a post' do
      User.destroy_all
      user = create(:user)
      posts = create_list(:post, 3)
      post_1 = posts[0]
      create(:circle_member, user_id: post_1.author_id, circle_id: post_1.circle_id)
      comments_to_retrieve = create_list(:comment, 3, post_id: post_1.id)
      post_2 = posts[1]
      create_list(:comment, 2, post_id: post_2.id)

      get "/api/v0/users/#{post_1.author_id}/circles/#{post_1.circle_id}/posts/#{post_1.id}/comments"
      expect(response.status).to eq(200)
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(data.count).to eq(3)
      returned_comment_ids = data.map { |comment| comment[:id].to_i }
      expect(returned_comment_ids.sort).to eq(comments_to_retrieve.map(&:id).sort)
      
      # Check for author_display_name in response
      expect(data.first[:attributes]).to have_key(:author_display_name)
    end

    it 'includes all replies to comments in hierarchical order' do
      User.destroy_all
      users = create_list(:user, 4)
      #add users to circle
      circle = create(:circle, user_id: users[0].id)
      create(:circle_member, user_id: users[1].id, circle_id: circle.id)
      create(:circle_member, user_id: users[2].id, circle_id: circle.id)
      create(:circle_member, user_id: users[3].id, circle_id: circle.id)
      #post with two top-level comments
      post = create(:post, author_id: users[0].id, circle_id: circle.id)
      # comment with no replies
      create(:comment, post_id: post.id, author_id: users[3].id)
      # thread: comment, reply, and two sub-replies
      comment = create(:comment, post_id: post.id, author_id: users[1].id)
      reply = create(:comment, post_id: post.id, author_id: users[2].id, parent_comment_id: comment.id)
      sub_reply_1 = create(:comment, post_id: post.id, author_id: users[0].id, parent_comment_id: reply.id)
      sub_reply_2 = create(:comment, post_id: post.id, author_id: users[2].id, parent_comment_id: reply.id)

      get "/api/v0/users/#{users[0].id}/circles/#{post.circle_id}/posts/#{post.id}/comments"
      expect(response.status).to eq(200)
      comments = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(comments.count).to eq(2)
      
      # Check for top-level comment attributes
      comment_response = comments.find { |c| c[:id].to_i == comment.id }
      expect(comment_response[:attributes][:comment_text]).to eq(comment.comment_text)
      expect(comment_response[:attributes][:author_id]).to eq(comment.author_id)
      expect(comment_response[:attributes]).to have_key(:author_display_name)
      
      # Check for nested replies
      replies = comment_response[:attributes][:replies][:data]
      expect(replies.count).to eq(1)
      
      # Check reply attributes
      reply_response = replies.first
      expect(reply_response[:attributes][:parent_comment_id]).to eq(comment.id)
      expect(reply_response[:attributes][:comment_text]).to eq(reply.comment_text)
      expect(reply_response[:attributes]).to have_key(:author_display_name)
      
      # Check sub-replies
      sub_replies = reply_response[:attributes][:replies][:data]
      expect(sub_replies.count).to eq(2)
      
      # Check sub-reply attributes
      sub_reply_1_response = sub_replies.find { |sr| sr[:id].to_i == sub_reply_1.id }
      expect(sub_reply_1_response[:attributes][:parent_comment_id]).to eq(reply.id)
      expect(sub_reply_1_response[:attributes][:comment_text]).to eq(sub_reply_1.comment_text)
      expect(sub_reply_1_response[:attributes]).to have_key(:author_display_name)
      
      sub_reply_2_response = sub_replies.find { |sr| sr[:id].to_i == sub_reply_2.id }
      expect(sub_reply_2_response[:attributes][:parent_comment_id]).to eq(reply.id)
      expect(sub_reply_2_response[:attributes][:comment_text]).to eq(sub_reply_2.comment_text)
      expect(sub_reply_2_response[:attributes]).to have_key(:author_display_name)
    end
  end

  describe 'get a comment' do
    before(:all) do
      User.destroy_all
      @user = create(:user)
      comments = create_list(:comment, 3)
      random_number = Random.new.rand(3)
      @comment_to_return = comments[random_number]
      @post = @comment_to_return.post
      @circle = @post.circle
      create(:circle_member, user_id: @user.id, circle_id: @circle.id)
    end
    it 'gets a comment' do
      get "/api/v0/users/#{@user.id}/circles/#{@circle.id}/posts/#{@post.id}/comments/#{@comment_to_return.id}"

      expect(response.status).to eq(200)
      data = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(data[:type]).to eq("comment")
      attributes = data[:attributes]
      expect(attributes[:id]).to eq(@comment_to_return.id)
      expect(attributes[:comment_text]).to eq(@comment_to_return.comment_text)
      expect(attributes[:author_id]).to eq(@comment_to_return.author_id)
      expect(attributes[:post_id]).to eq(@comment_to_return.post_id)
      expect(attributes[:parent_comment_id]).to eq(@comment_to_return.parent_comment_id)
      expect(attributes).to have_key(:author_display_name)
      expect(attributes).to have_key(:replies)
    end

    it 'returns 404 Not Found if the comment does not exist' do
      get "/api/v0/users/#{@user.id}/circles/#{@circle.id}/posts/#{@post.id}/comments/1"

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).
      to eq("Couldn't find Comment with 'id'=1")
    end
  end
  describe 'create a comment' do
    it 'creates a comment' do
      User.destroy_all
      circle_member = create(:circle_member)
      circle = circle_member.circle
      member = circle_member.user
      post = create(:post, circle_id: circle.id)

      params = {
        comment_text: 'This is a comment'
      }

      post "/api/v0/users/#{member.id}/circles/#{circle.id}/posts/#{post.id}/comments", params: params

      expect(response.status).to eq(201)
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(data[:type]).to eq("comment")
      expect(data[:attributes][:comment_text]).to eq("This is a comment")
      expect(data[:attributes][:author_id]).to eq(member.id)
      expect(data[:attributes][:post_id]).to eq(post.id)
      expect(data[:attributes][:parent_comment_id]).to eq(nil)
      expect(data[:attributes]).to have_key(:author_display_name)
      expect(data[:attributes]).to have_key(:replies)
      expect(data[:attributes][:replies][:data]).to be_empty

      expect(Comment.count).to eq(1)

      comment = Comment.first

      params = {
        comment_text: 'this is a sub-comment',
        parent_comment_id: comment.id
      }

      post "/api/v0/users/#{member.id}/circles/#{circle.id}/posts/#{post.id}/comments", params: params
      data = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(data[:attributes][:comment_text]).to eq("this is a sub-comment")
      expect(data[:attributes][:parent_comment_id]).to eq(comment.id)
      expect(data[:attributes]).to have_key(:author_display_name)
      expect(data[:attributes]).to have_key(:replies)
      expect(data[:attributes][:replies][:data]).to be_empty

      expect(Comment.count).to eq(2)
    end
  end

  describe 'update a comment' do
    before(:all) do
      User.destroy_all
      @author = create(:user)
      @owner = create(:user)
      @circle_id = create(:circle, user_id: @owner.id).id
      create(:circle_member, user_id: @author.id, circle_id: @circle_id)
      @post_id = create(:post, circle_id: @circle_id, author_id: @author.id).id
    end
    it 'updates a comment if the user is the author' do
      comment_id = create(:comment, author_id: @author.id, post_id: @post_id).id

      params = {comment_text: 'This should be allowed'}
      time = Time.now

      put "/api/v0/users/#{@author.id}/circles/#{@circle_id}/posts/#{@post_id}/comments/#{comment_id}", params: params

      expect(response.status).to eq(200)
      data = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(data[:attributes][:comment_text]).to eq("This should be allowed")
      expect(data[:attributes][:updated_at]).to be > time.iso8601(3)
      expect(data[:attributes]).to have_key(:author_display_name)
      expect(data[:attributes]).to have_key(:replies)
      time = data[:attributes][:updated_at]

      params = {comment_text: 'This should not be allowed'}

      put "/api/v0/users/#{@owner.id}/circles/#{@circle_id}/posts/#{@post_id}/comments/#{comment_id}", params: params

      expect(response.status).to eq(401)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).
      to eq("Unauthorized")

      comment = Comment.find(comment_id)
      expect(comment.comment_text).to eq("This should be allowed")
      expect(comment.updated_at.iso8601(3)).to eq(time)
    end

    it 'returns an error if the comment does not exist' do
      put "/api/v0/users/#{@author.id}/circles/#{@circle_id}/posts/#{@post_id}/comments/1"

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).
      to eq("Couldn't find Comment with 'id'=1")
    end
  end

  describe 'delete a comment' do
    before(:all) do
      User.destroy_all
      @author = create(:user)
      @owner = create(:user)
      @circle_id = create(:circle, user_id: @owner.id).id
      create(:circle_member, user_id: @author.id, circle_id: @circle_id)
      @post = create(:post, circle_id: @circle_id, author_id: @author.id)
      @post_id = @post.id
      @comment_id = create(:comment, author_id: @author.id, post_id: @post_id).id
    end

    it 'deletes a comment if the user is the author' do
      expect(Comment.count).to eq(1)
      expect(@post.comments.count).to eq(1)

      delete "/api/v0/users/#{@author.id}/circles/#{@circle_id}/posts/#{@post_id}/comments/#{@comment_id}"

      expect(response.status).to eq(204)
      expect(Comment.count).to eq(0)
      expect(@post.comments.count).to eq(0)
    end

    it 'deletes a comment if the user is the circle owner' do
      expect(Comment.count).to eq(1)
      expect(@post.comments.count).to eq(1)

      delete "/api/v0/users/#{@owner.id}/circles/#{@circle_id}/posts/#{@post_id}/comments/#{@comment_id}"

      expect(response.status).to eq(204)
      expect(Comment.count).to eq(0)
      expect(@post.comments.count).to eq(0)
    end

    it 'sends 401 Unauthorized if user is not the author or circle owner' do
      unauthorized_user = create(:user)
      create(:circle_member, user_id: unauthorized_user.id, circle_id: @circle_id)

      expect(Comment.count).to eq(1)
      expect(@post.comments.count).to eq(1)

      delete "/api/v0/users/#{unauthorized_user.id}/circles/#{@circle_id}/posts/#{@post_id}/comments/#{@comment_id}"

      expect(response.status).to eq(401)
      expect(Comment.count).to eq(1)
      expect(@post.comments.count).to eq(1)
    end
  end
end