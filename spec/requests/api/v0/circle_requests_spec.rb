require 'rails_helper' 

RSpec.describe 'Circles API', type: :request do
  before(:all) do
    User.destroy_all
    @users = create_list(:user, 10)
    @circles = create_list(:circle, 25)
  end

  describe 'get all circles' do
    it 'gets all circles' do
      get '/api/v0/circles'

      expect(response.status).to eq(200)

      data = JSON.parse(response.body, symbolize_names: true)
      circles = data[:data]

      expect(circles.count).to eq 25
      sample_circles = circles.sample(5)

      circles.each do |circle|
        current_circle = Circle.find(circle[:id])
        expect(circle[:id]).to eq(current_circle.id.to_s)
        expect(circle[:type]).to eq("circle")
        
        attributes = circle[:attributes]

        expect(attributes[:user_id]).to eq(current_circle.user_id)
        expect(attributes[:name]).to eq(current_circle.name)
        expect(attributes[:description]).to eq(current_circle.description)
      end
    end
  end
  
  describe 'get all circles for user' do
    it 'sends a list of all circles that a user belongs to or owns' do
      user = @users.first
      # create circles that user just belongs to
      user_circles = Circle.all.sample(5)
      user_circles.each do |circle|
        create(:circle_member, user_id: user.id, circle_id: circle.id)
      end
      # create circles that user owns
      create_list(:circle, 2, user_id: user.id)

      get "/api/v0/users/#{user.id}/circles"

      expect(response.status).to eq(200)

      data = JSON.parse(response.body, symbolize_names: true)
      circles = data[:data]

      expect(circles.count).to eq 7

      circles.each do |circle|
        current_circle = Circle.find(circle[:id])
        expect(circle[:id]).to eq(current_circle.id.to_s)
        expect(circle[:type]).to eq("circle")
        
        attributes = circle[:attributes]

        expect(attributes[:user_id]).to eq(current_circle.user_id)
        expect(attributes[:name]).to eq(current_circle.name)
        expect(attributes[:description]).to eq(current_circle.description)
      end
    end

    it 'sends an empty array if user does not belong to any circles' do
      loser_user = create(:user)

      get "/api/v0/users/#{loser_user.id}/circles"

      expect(response.status).to eq(200)

      data = JSON.parse(response.body, symbolize_names: true)
      circles = data[:data]
      expect(circles.count).to eq 0
    end

    it 'sends 404 Not Found if invalid user id is passed in' do
      get "/api/v0/users/299/circles"
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).to eq("Couldn't find User with 'id'=299")
    end
  end

  describe 'get one circle' do
    it 'sends all circle attributes if valid id is passed in' do
      circle_1 = Circle.second

      get "/api/v0/circles/#{circle_1.id}"

      expect(response.status).to eq(200)

      data = JSON.parse(response.body, symbolize_names: true)
      circle = data[:data]

      expect(data.count).to eq 1
      
      attributes = circle[:attributes]
      expect(attributes[:user_id]).to eq(circle_1.user_id)
      expect(attributes[:name]).to eq(circle_1.name)
      expect(attributes[:description]).to eq(circle_1.description)
    end

    it 'sends 404 Not Found if invalid circle id is passed in' do
      get "/api/v0/circles/342"

      expect(response.status).to eq(404)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to eq("Couldn't find Circle with 'id'=342")
    end
  end

  describe 'create a circle' do
    it 'creates a circle with valid attributes' do
      user_id = @users.first.id
      new_circle_attributes = {circle: {
        "user_id" => user_id,
        "name": "College Friends",
        "description": "Friends from college"
      }}
      post "/api/v0/users/#{user_id}/circles",params: new_circle_attributes

      expect(response.status).to eq(201)
      expect(Circle.count).to eq(26)

      circle = Circle.order(:created_at).last
      data = JSON.parse(response.body, symbolize_names: true)
      attributes = data[:data][:attributes]

      expect(attributes[:user_id]).to eq(user_id)
      expect(attributes[:name]).to eq("College Friends")
      expect(attributes[:description]).to eq("Friends from college")

      Circle.destroy(circle.id)
    end

    it 'creates a circle member for the user' do
      user_id = @users.first.id
      new_circle_attributes = {circle: {
        "user_id" => user_id,
        "name": "College Friends",
        "description": "Friends from college"
      }}
      post "/api/v0/users/#{user_id}/circles", params: new_circle_attributes

      expect(response.status).to eq(201)
      expect(CircleMember.count).to eq(1)
      expect(CircleMember.where(user_id: user_id, circle_id: Circle.last.id)).to be_present
    end

    it 'sends 422 Unprocessable Entity if invalid attributes are passed in' do
      user_id = @users.first.id
      new_circle_attributes = {circle: {
        "user_id" => user_id,
        "name": "College Friends"
      }}
      post "/api/v0/users/#{user_id}/circles", params: new_circle_attributes

      expect(response.status).to eq(422)
      expect(Circle.count).to eq(25)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:errors]).to eq("Validation failed: Description can't be blank")
    end
  end

  describe 'delete a circle' do
    before(:all) do
      @valid_circle = Circle.second
    end
    it 'deletes a circle with valid id and password' do
      user = @valid_circle.user
      user.update(password: "therightpassword", password_confirmation: "therightpassword")
      body = { "password": "therightpassword" }

      delete "/api/v0/users/#{user.id}/circles/#{@valid_circle.id}", params: body

      expect(response.status).to eq(204)
      expect(Circle.count).to eq(24)
      expect(Circle.find_by(id: @valid_circle.id)).to eq(nil)
    end

    it 'sends 404 Not Found if invalid circle id is passed in' do
      user = @users.first
      body = { "password": user.password}
      delete "/api/v0/users/#{user.id}/circles/239", params: body

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).to eq("Couldn't find Circle with 'id'=239")
    end

    it 'sends 401 Unauthorized if invalid password is passed in' do
      body = { "password": "password" }
      user = @valid_circle.user
      
      delete "/api/v0/users/#{user.id}/circles/#{@valid_circle.id}", params: body

      expect(response.status).to eq(401)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).to eq("Unauthorized")
    end
  end
end