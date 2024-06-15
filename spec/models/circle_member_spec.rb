require 'rails_helper'

RSpec.describe CircleMember, type: :model do
  describe 'relationships' do
    it { should belong_to :user }
    it { should belong_to :circle }
  end

  describe 'validations' do
    it { should validate_presence_of :circle_id}
    it { should validate_presence_of :user_id}
  end
end