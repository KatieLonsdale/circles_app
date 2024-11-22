require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET #index' do
    it 'returns a 204 No Content response' do
      get :index
      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end
  end
end
