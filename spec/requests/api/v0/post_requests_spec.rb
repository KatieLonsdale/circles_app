require 'rails_helper'

RSpec.describe 'Posts API', type: :request do
  before(:all) do
    User.destroy_all
    create_list(:circle_member, 10)
  end

  describe 'get all posts for circle' do
    it 'sends a list of all posts for a circle' do
      # create circle for test
      circle_id = create(:circle).id
      # grab user and add them to circle
      user = User.all.sample
      create(:circle_member, user_id: user.id, circle_id: circle_id)
      # create posts, contents, and comments for circle
      posts = create_list(:post, 3, circle_id: circle_id)
      post_ids = posts.map(&:id)
      post_ids.each do |post_id|
        contents = create_list(:content, rand(3), post_id: post_id)
        comments = create_list(:comment, rand(3), post_id: post_id)
      end
      params = {user_id: user.id}

      get "/api/v0/circles/#{circle_id}/posts", params: params

      expect(response.status).to eq(200)
      data = JSON.parse(response.body, symbolize_names: true)
      response_posts = data[:data]
      expect(response_posts.dig(0, :type)).to eq("post")
      expect(response_posts.count).to eq 3

      attributes = response_posts.dig(0, :attributes)
      post = posts.first
      expect(attributes[:id]).to eq(post.id)
      expect(attributes[:caption]).to eq(post.caption)
      expect(attributes[:created_at]).to eq(post.created_at.iso8601(3))
      expect(attributes[:updated_at]).to eq(post.updated_at.iso8601(3))
      attributes[:contents][:data].each do |content|
        actual_content = Content.find(content[:id].to_i)
        expect(actual_content.post_id).to eq(post.id)
        expect(content[:type]).to eq("content")
        content_attributes = content[:attributes]
        expect(content_attributes[:video_url]).to eq(actual_content.video_url)
        expect(content_attributes[:image_url]).to eq(actual_content.image_url)
      end
      attributes[:comments][:data].each do |comment|
        actual_comment = Comment.find(comment[:id].to_i)
        expect(actual_comment.post_id).to eq(post.id)
        expect(comment[:type]).to eq("comment")
        comment_attributes = comment[:attributes]
        expect(comment_attributes[:author_id]).to eq(actual_comment.author_id)
        expect(comment_attributes[:parent_comment_id]).to eq(actual_comment.parent_comment_id)
        expect(comment_attributes[:comment_text]).to eq(actual_comment.comment_text)
        expect(comment_attributes[:created_at]).to eq(actual_comment.created_at.iso8601(3))
        expect(comment_attributes[:updated_at]).to eq(actual_comment.updated_at.iso8601(3))
      end
    end

    it 'sends 404 Not Found if invalid circle id is passed in' do
      user = User.first
      get "/api/v0/circles/2/posts", params: {user_id: user.id}

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).
      to eq("Couldn't find Circle with 'id'=2")
    end

    it 'send 401 Unauthorized if user is not a member of the circle' do
      # fill out this test
    end
  end
end