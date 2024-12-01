require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do
  let!(:user) { create(:user, email: 'test@example.com', password: 'password') }
  let(:valid_credentials) { { email: 'test@example.com', password: 'password' } }
  let(:invalid_credentials) { { email: 'test@example.com', password: 'wrongpassword' } }

  describe 'POST /sessions' do
    context 'when credentials are valid' do
      before { post '/sessions', params: valid_credentials }

      it 'returns a token' do
        expect(json['token']).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when credentials are invalid' do
      before { post '/sessions', params: invalid_credentials }

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
