require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'relationships' do
    it { should have_many :circles }
    it { should have_many :circle_members }
  end

  describe 'validations' do
    before(:all) do
      User.destroy_all
      create(:user)
    end
    it { should validate_presence_of :email}
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of :password}
    it { should validate_presence_of :display_name}
  end

  describe 'instance methods' do
    describe 'add_circle' do
      it 'adds a circle to a user' do
        # fill out
      end
    end
  end
end

