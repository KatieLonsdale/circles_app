require 'rails_helper'

RSpec.describe CommentUserReaction, type: :model do
  describe 'relationships' do
    it { should belong_to :comment }
  end

  describe 'validations' do
    it { should validate_presence_of :comment_id }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :reaction_id }
  end
end