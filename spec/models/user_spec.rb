require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'relationships' do
    it { should have_many :circles }
    it { should have_many(:posts).through(:circles) }
  end

  describe 'validations' do
    it { should validate_presence_of :email}
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of :password}
    it { should validate_presence_of :display_name}
  end
end

