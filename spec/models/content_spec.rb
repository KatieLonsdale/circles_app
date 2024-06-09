require 'rails_helper'

RSpec.describe Content, type: :model do
  describe 'relationships' do
    it { should belong_to :post }
  end

  describe 'validations' do
    it { should validate_presence_of :post_id }
  end
end
