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

      get "/api/v0/users/#{user.id}/circles/#{circle_id}/posts"

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
      get "/api/v0/users/#{user.id}/circles/2/posts"

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).
      to eq("Couldn't find Circle with 'id'=2")
    end

    it 'send 401 Unauthorized if user is not a member of the circle' do
      circle = create(:circle)
      user = create(:user)

      get "/api/v0/users/#{user.id}/circles/#{circle.id}/posts"

      expect(response.status).to eq(401)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).
      to eq("Unauthorized")
    end
  end

  describe 'create a post' do
    before(:all) do
      @users = create_list(:user, 2)
      @author = @users[0]

      @valid_params = {
        caption: "This is a caption", 
        contents: {
          "image_url": "https://www.example.com/photo.jpg"
        }
      }
    end
    it 'creates a new post with the user as the author' do
      circle_member = create(:circle_member, user_id: @author.id)
      circle_id = circle_member.circle_id

      post "/api/v0/users/#{@author.id}/circles/#{circle_id}/posts", params: @valid_params
      expect(response.status).to eq(201)
      data = JSON.parse(response.body, symbolize_names: true)[:data]
      # correct post
      expect(data[:attributes][:caption]).to eq("This is a caption")
      expect(data[:attributes][:author_id]).to eq(@author.id)
      # correct content
      content = data.dig(:attributes, :contents, :data, 0)
      expect(content[:type]).to eq("content")
      expect(content.dig(:attributes, :image_url)).to eq("https://www.example.com/photo.jpg")
      expect(content.dig(:attributes, :video_url)).to eq(nil)
      # no comments
      expect(data.dig(:attributes, :comments, :data)).to eq([])

      expect(Post.count).to eq(1)
      expect(Content.count).to eq(1)
    end

    it 'sends 404 Not Found if invalid circle id is passed in' do
      post "/api/v0/users/#{@author.id}/circles/2/posts", params: @valid_params

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).
      to eq("Couldn't find Circle with 'id'=2")
    end

    it 'sends 401 Unauthorized if user is not a member of the circle' do
      circle = create(:circle)
      user = create(:user)
      params = {
        caption: "This is a caption", 
        contents: {
          "photo_url": "https://www.example.com/photo.jpg"
        }
      }

      post "/api/v0/users/#{user.id}/circles/#{circle.id}/posts", params: params

      expect(response.status).to eq(401)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).
      to eq("Unauthorized")
    end
  end

  describe 'update a post' do
    it 'updates a post' do
      post = create(:post)
      author_id = post.author_id
      circle_id = post.circle.id
      create(:circle_member, user_id: author_id, circle_id: circle_id)

      new_caption = {caption: "This is a new caption"}

      put "/api/v0/users/#{author_id}/circles/#{circle_id}/posts/#{post.id}", params: new_caption
      time = Time.now

      expect(response.status).to eq(200)
      data = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(data[:attributes][:caption]).to eq("This is a new caption")
      expect(data[:attributes][:updated_at]).to be > time.iso8601(3)
    end
  end

  describe 'delete a post' do
    it 'deletes a post if the user is its author or the circle owner' do
      # author deletes it
      create_list(:post, 3)
      post = Post.first
      circle_id = post.circle.id
      author_id = post.author_id
      create(:circle_member, user_id: author_id, circle_id: circle_id)

      delete "/api/v0/users/#{author_id}/circles/#{circle_id}/posts/#{post.id}"

      expect(response.status).to eq(204)
      expect(Post.count).to eq(2)
      expect(Post.find_by(id: post.id)).to eq(nil)

      # circle owner deletes it
      post = Post.first
      user = create(:user)
      post.update(author_id: user.id)
      circle = post.circle
      circle_owner_id = circle.user_id

      delete "/api/v0/users/#{circle_owner_id}/circles/#{circle.id}/posts/#{post.id}"

      expect(response.status).to eq(204)
      expect(Post.count).to eq(1)
      expect(Post.find_by(id: post.id)).to eq(nil)
    end

    it 'sends 401 Unauthorized if user is not the author or circle owner' do
      users = create_list(:user, 3)
      post = create(:post)
      post.update(author_id: users[0].id)
      circle = post.circle
      circle.update(user_id: users[1].id)
      unauthorized_user = users[2]

      delete "/api/v0/users/#{unauthorized_user.id}/circles/#{circle.id}/posts/#{post.id}"

      expect(response.status).to eq(401)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).
      to eq("Unauthorized")

      expect(Post.count).to eq(1)
    end
  end
end