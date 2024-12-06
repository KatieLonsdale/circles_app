require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do
  before(:all) do
    User.destroy_all
    @user = create(:user, email: 'test@example.com', password: 'password')
    @valid_credentials = { email: 'test@example.com', password: 'password' }
    @invalid_credentials = { email: 'test@example.com', password: 'wrongpassword' }
  end

  describe 'POST /sessions' do
    context 'when credentials are valid' do
      before { post '/sessions', params: @valid_credentials }

      it 'returns a token' do
        response = json
        # require 'pry'; binding.pry
        expect(response['token']).not_to be_nil
        user_attributes = response['user']['data']['attributes']
        expect(user_attributes['display_name']).to eq(@user.display_name)
        expect(user_attributes['notification_frequency']).to eq(@user.notification_frequency)
        expect(user_attributes['email']).to eq('test@example.com')
        expect(user_attributes).to_not have_key(:password_digest)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when credentials are invalid' do
      before { post '/sessions', params: @invalid_credentials }

      it 'returns an error message' do
        expect(json['error']).to eq('Invalid credentials')
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

# Helper method for parsing JSON responses
def json
  JSON.parse(response.body)
end
