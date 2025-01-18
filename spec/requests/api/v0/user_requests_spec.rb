require 'rails_helper' 

RSpec.describe 'Users API', type: :request do
  before(:all) do
    User.destroy_all
    @all_users = create_list(:user, 10)
  end
  
  describe 'get all users' do
    it 'sends a list of all users' do
      @valid_headers = { "Authorization" => "c0d3b4s3d" }
      
      get '/api/v0/users', headers: @valid_headers

      expect(response.status).to eq(200)

      data = JSON.parse(response.body, symbolize_names: true)
      users = data[:data]

      expect(users.count).to eq 10

      users.each do |user|
        current_user = User.find(user[:id])
        expect(user[:id]).to eq(current_user.id.to_s)
        expect(user[:type]).to eq("user")
        
        attributes = user[:attributes]

        expect(attributes[:id]).to eq(current_user.id)
        expect(attributes[:email]).to eq(current_user.email)
        expect(attributes[:display_name]).to eq(current_user.display_name)
        expect(attributes).to_not have_key(:password_digest)
      end
    end
  end

  describe 'get one user' do
    it 'sends all user attributes if valid id is passed in' do
      user_1 = @all_users[Random.rand(10)]

      get "/api/v0/users/#{user_1.id}", headers: @valid_headers

      expect(response.status).to eq(200)

      data = JSON.parse(response.body, symbolize_names: true)
      user = data[:data]

      expect(data.count).to eq 1
      
      attributes = user[:attributes]
      expect(attributes[:id]).to eq(user_1.id)
      expect(attributes[:email]).to eq(user_1.email)
      expect(attributes[:display_name]).to eq(user_1.display_name)
      expect(attributes[:notification_frequency]).to eq(user_1.notification_frequency)
      expect(attributes).to_not have_key(:password_digest)
    end

    it 'sends 404 Not Found if invalid user id is passed in' do
      get "/api/v0/users/239487", headers: @valid_headers

      expect(response.status).to eq(404)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to eq("Couldn't find User with 'id'=239487")
    end
  end

  describe 'create a user' do
    it 'creates a user with valid attributes' do
      new_user_attributes = {
        "email": "katie@email.com", 
        "display_name": "Katie", 
        "password": "password", 
        "password_confirmation": "password",
        "notifications_token": "valid_token_123"
      }
      post "/api/v0/users", headers: @valid_headers, params: new_user_attributes

      expect(response.status).to eq(201)
      expect(User.count).to eq(11)

      user_1 = User.first
      data = JSON.parse(response.body, symbolize_names: true)
      attributes = data[:data][:attributes]

      expect(attributes[:id]).to eq(user_1.id)
      expect(attributes[:email]).to eq(user_1.email)
      expect(attributes[:display_name]).to eq(user_1.display_name)
      expect(attributes).to_not have_key(:password_digest)
    end

    it 'sends 422 Unprocessable Entity if invalid attributes are passed in' do
      new_user_attributes = {
        "email": "katieemail.com", 
        "display_name": "Katie", 
        "password": "password", 
        "password_confirmation": "password",
        "notifications_token": "valid_token_123"
      }
      post "/api/v0/users", headers: @valid_headers, params: new_user_attributes

      expect(response.status).to eq(422)
      expect(User.count).to eq(10)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:errors]).to eq("Validation failed: Email must be a valid email address")

      new_user_attributes[:email] = "katie@email.com"
      new_user_attributes[:password_confirmation] = "password1"

      post "/api/v0/users", headers: @valid_headers, params: new_user_attributes

      expect(response.status).to eq(422)
      expect(User.count).to eq(10)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:errors]).to eq("Validation failed: Password confirmation doesn't match Password")
    end
  end

  describe 'update a user' do
    before(:all) do
      @user = @all_users[Random.rand(10)]
    end
    it 'updates a user with valid attributes' do
      @user[:notification_frequency] = "daily"

      @updated_user_attributes = {
        email: @user.email, 
        display_name: @user.display_name, 
        password: @user.password,
        notification_frequency: "live",
        last_tou_acceptance: "2024-06-15 20:32:49.843517"
      }
      put "/api/v0/users/#{@user.id}", headers: @valid_headers, params: @updated_user_attributes

      expect(response.status).to eq(204)
      updated_user = User.find(@user.id)
      expect(updated_user.notification_frequency).to eq("live")
      expect(updated_user.last_tou_acceptance).to eq("2024-06-15 20:32:49.843517")
    end

    it "can update without all fields included" do
      partial_user_attributes = {
        notification_frequency: "daily",
      }
      put "/api/v0/users/#{@user.id}", headers: @valid_headers, params: partial_user_attributes

      expect(response.status).to eq(204)
      updated_user = User.find(@user.id)
      expect(updated_user.notification_frequency).to eq("daily")
    end

    it 'sends 404 Not Found if invalid user id is passed in' do
      put "/api/v0/users/239487", headers: @valid_headers, params: @updated_user_attributes

      expect(response.status).to eq(404)
    end

    it 'sends 422 Unprocessable Entity if invalid attributes are passed in' do
      put "/api/v0/users/#{@user.id}", headers: @valid_headers, params: { email: "katieemail.com" }
      expect(response.status).to eq(422)
      expect(@user.email).to_not eq("katieemail.com")
    end
  end

  describe 'delete a user' do
    it 'deletes a user with valid id' do
      user = @all_users[Random.rand(10)]

      delete "/api/v0/users/#{user.id}", headers: @valid_headers

      expect(response.status).to eq(204)
      expect(User.count).to eq(9)
      expect(User.find_by(id: user.id)).to eq(nil)
    end

    it 'sends 404 Not Found if invalid user id is passed in' do
      delete "/api/v0/users/239487", headers: @valid_headers

      expect(response.status).to eq(404)
    end
  end

  describe 'authenticate a user' do
    it 'authenticates a user with valid email and password' do
      user = @all_users[Random.rand(10)]

      authenticate_params = {
        email: user.email,
        password: user.password
      }

      post "/api/v0/users/authenticate", params: authenticate_params

      expect(response.status).to eq(200)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:data][:id]).to eq(user.id.to_s)
      
      attributes = data[:data][:attributes]
      expect(attributes[:email]).to eq(user.email)
      expect(attributes[:display_name]).to eq(user.display_name)
      expect(attributes[:notification_frequency]).to eq(user.notification_frequency)
      expect(attributes).to_not have_key(:password_digest)
    end

    it 'sends 404 Not Found if invalid email is passed in' do
      authenticate_params = {
        email: "user.email",
        password: "wrongpassword"
      }
      post "/api/v0/users/authenticate", params: authenticate_params

      expect(response.status).to eq(401)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:errors]).to eq("Invalid email or password")
    end
  end
end