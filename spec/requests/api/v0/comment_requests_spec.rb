require 'rails_helper'

RSpec.describe 'Comments API', type: :request do
  describe 'create a comment' do
    it 'creates a comment' do
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

      expect(Comment.count).to eq(2)
    end
  end

  describe 'update a comment' do
    before(:all) do
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
end