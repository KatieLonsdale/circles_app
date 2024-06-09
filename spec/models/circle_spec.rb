require 'rails_helper'

RSpec.describe Circle, type: :model do
  describe 'relationships' do
    it { should have_many :posts }
    it { should belong_to :user }
    # it { should have_many(:markets).through(:market_vendors) }
  end

  describe 'validations' do
    it { should validate_presence_of :name}
    it { should validate_presence_of :user_id}
    it { should validate_presence_of :description}
  end
end