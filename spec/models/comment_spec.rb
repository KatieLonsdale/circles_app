require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'relationships' do
    it { should belong_to :post }
    it { should have_many(:comment_user_reactions ).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of :post_id }
    it { should validate_presence_of :author_id }
    it { should validate_presence_of :comment_text }
  end
end