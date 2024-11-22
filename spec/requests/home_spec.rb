require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    it 'returns a 200 response' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('{"Status":"Up"}')
    end
  end
end
