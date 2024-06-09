require 'rails_helper'

RSpec.describe Reaction, type: :model do
  describe 'validations' do
    it { should validate_presence_of :image_url }
  end
end
