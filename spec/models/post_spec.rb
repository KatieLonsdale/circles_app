require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'relationships' do
    it { should belong_to :circle }
    it { should have_many(:comments ).dependent(:destroy) }
    it { should have_many(:post_user_reactions).dependent(:destroy) }
    it { should have_many :content }
    it { should have_many(:comment_user_reactions).through(:comments) }

  end

  describe 'validations' do
    it { should validate_presence_of :circle_id}
    it { should validate_presence_of :author_id}
  end
end
