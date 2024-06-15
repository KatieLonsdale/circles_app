require 'rails_helper'

RSpec.describe 'Posts API', type: :request do
  before(:all) do
    User.destroy_all
    create_list(:circle_member, 20)
    create_list(:post, 10)
    create_list(:content, 7)
    create_list(:comment, 10)
  end

  describe 'get all posts for circle' do
    it 'sends a list of all posts for a circle' do
      circle_id = Circle.all.sample.id
      user = User.joins(:circle_members).where('circle_members.circle_id = circle_id').sample
      posts = Post.where(circle_id: circle_id)
      contents = Content.where(post_id: posts.map(&:id))
      comments = Comment.where(post_id: posts.map(&:id))
      params = {user_id: user.id}

      get "/api/v0/circles/#{circle_id}/posts"

      expect(response.status).to eq(200)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:type]).to eq("post")
      expect(data.count).to eq 3

      attributes = data[:attributes]
      posts.each do |post|
        expect(attributes[:id]).to eq(post.id)
        expect(attributes[:caption]).to eq(post.caption)
        expect(attributes[:created_at]).to eq(post.created_at)
        expect(attributes[:updated_at]).to eq(post.updated_at)
        attributes[:contents].each do |content|
          actual_content = contents.find(content[:id])
          expect(actual_content.post_id).to eq(post.id)
          expect(content[:type]).to eq("content")
          content_attributes = content[:attributes]
          expect(content_attributes[:video_url]).to eq(actual_content.video_url)
          expect(content_attributes[:image_url]).to eq(actual_content.image_url)
        end
        attributes[:comments].each do |comment|
          actual_comment = comments.find(comment[:id])
          expect(actual_comment.post_id).to eq(post.id)
          expect(comment[:type]).to eq("comment")
          comment_attributes = comment[:attributes]
          expect(comment_attributes[:parent_comment_id]).to eq(actual_comment.parent_comment_id)
          expect(comment_attributes[:user_id]).to eq(actual_comment.user_id)
          expect(comment_attributes[:comment_text]).to eq(actual_comment.comment_text)
          expect(comment_attributes[:created_at]).to eq(actual_comment.created_at)
          expect(comment_attributes[:updated_at]).to eq(actual_comment.updated_at)
        end
      end
    end

    it 'sends 404 Not Found if invalid circle id is passed in' do
      get "/api/v0/circles/2/posts"

      expect(response.status).to eq(404)
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body[:error]).to eq("Circle with id=2 not found")
    end
  end
end