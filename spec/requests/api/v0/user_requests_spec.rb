require 'rails_helper' 

describe 'Users API', type: :request do
  User.destroy_all
  before(:all) do
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

    it 'sends a 401 error if no authorization header is provided' do
      get '/api/v0/users'

      expect(response.status).to eq(401)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data).to have_key(:errors)
      expect(data[:errors][0]).to have_key(:detail)
      expect(data[:errors][0][:detail])
      .to eq("Access Denied")
    end

    it 'sends a 401 error if invalid authorization header is provided' do
      invalid_headers = { "Authorization" => "nonono"}
      response = get '/api/v0/users', headers: invalid_headers

      expect(data).to have_key(:errors)
      expect(data[:errors][0]).to have_key(:detail)
      expect(data[:errors][0][:detail])
      .to eq("Access Denied")
    end
  end

  describe 'get one user' do
    it 'sends all user attributes if valid id is passed in' do
      user = @all_users[Random.rand(10)]

      get "/api/v0/users/#{user.id}", headers: @valid_headers

      expect(response.status).to eq(200)

      data = JSON.parse(response.body, symbolize_names: true)
      user = data[:data]

      expect(data.count).to eq 1
      
      attributes = user[:attributes]

      expect(attributes[:id]).to eq(user.id)
      expect(attributes[:email]).to eq(user.email)
      expect(attributes[:display_name]).to eq(user.display_name)
      expect(attributes[:notification_frequency]).to eq(user.notification_frequency)
      expect(attributes).to_not have_key(:password_digest)
    end

    it 'sends 404 Not Found if invalid user id is passed in' do
      get "/api/v0/users/239487", headers: @valid_headers

      expect(response.status).to eq(404)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data).to have_key(:errors)
      expect(data[:errors][0]).to have_key(:detail)
      expect(data[:errors][0][:detail]).to eq("User not found")
    end
  end

  describe 'create a user' do
    it 'creates a user with valid attributes' do
      new_user_attributes = {
        "email": "katie@email.com", 
        "display_name": "Katie", 
        "password": "password", 
        "password_confirmation": "password"
      }
      post "/api/v0/users", headers: @valid_headers, params: new_user_attributes

      expect(response.status).to eq(201)
      expect(User.count).to eq(11)
      data = JSON.parse(response.body, symbolize_names: true)

      attributes = data[:data]
      expect(attributes[:id]).to eq(User.last.id)
      expect(attributes[:email]).to eq(User.last.email)
      expect(attributes[:display_name]).to eq(User.last.display_name)
      expect(attributes).to_not have_key(:password_digest)
    end

    it 'sends 422 Unprocessable Entity if invalid attributes are passed in' do
      new_user_attributes = {
        "email": "katieemail.com", 
        "display_name": "Katie", 
        "password": "password", 
        "password_confirmation": "password"
      }
      post "/api/v0/users", headers: @valid_headers, params: new_user_attributes

      expect(response.status).to eq(422)
      expect(User.count).to eq(10)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:errors][0]).to have_key(:detail)
      expect(data[:errors][0][:detail]).to eq("Email is invalid")

      new_user_attributes.email = "katie@email.com"
      new_user_attributes.password_confirmation = "password1"

      post "/api/v0/users", headers: @valid_headers, params: new_user_attributes

      expect(response.status).to eq(422)
      expect(User.count).to eq(10)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data.dig(:errors, 0, :detail)).to eq("Password confirmation doesn't match Password")
    end
  end

  describe 'update a user' do
    before(:all) do
      @user = @all_users[Random.rand(10)]
    end
    it 'updates a user with valid attributes' do
      @user.notification_frequency = "daily"

      @updated_user_attributes = {
        notification_frequency: "live"
      }

      put "/api/v0/users/#{@user.id}", headers: @valid_headers, params: @updated_user_attributes

      expect(response.status).to eq(204)
      expect(@user.notification_frequency).to eq("live")
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
    end

    it 'sends 404 Not Found if invalid user id is passed in' do
      delete "/api/v0/users/239487", headers: @valid_headers

      expect(response.status).to eq(404)
    end
  end
end