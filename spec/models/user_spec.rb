require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'relationships' do
    it { should have_many :circles }
  end

  describe 'validations' do
    User.create(email: "email@email.com", password: "password", display_name: "display_name")
    it { should validate_presence_of :email}
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of :password}
    it { should validate_presence_of :display_name}
  end
end

