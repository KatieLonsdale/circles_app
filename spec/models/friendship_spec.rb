require 'rails_helper'

RSpec.describe Friendship, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:friend).class_name('User') }
  end

  describe 'validations' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    
    subject { Friendship.create(user: user1, friend: user2) }
    
    it { should validate_uniqueness_of(:user_id).scoped_to(:friend_id).with_message('friendship already exists') }
    
    it 'should not allow self-friendship' do
      user = create(:user)
      friendship = build(:friendship, user: user, friend: user)
      expect(friendship).not_to be_valid
      expect(friendship.errors[:friend_id]).to include("can't be the same as user")
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, accepted: 1, rejected: 2) }
  end

  describe 'scopes' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user3) { create(:user) }
    
    before do
      @pending_friendship = create(:friendship, user: user1, friend: user2, status: :pending)
      @accepted_friendship = create(:friendship, user: user1, friend: user3, status: :accepted)
      @rejected_friendship = create(:friendship, user: user2, friend: user3, status: :rejected)
    end
    
    it 'returns pending friendships' do
      expect(Friendship.pending).to include(@pending_friendship)
      expect(Friendship.pending).not_to include(@accepted_friendship, @rejected_friendship)
    end
    
    it 'returns accepted friendships' do
      expect(Friendship.accepted).to include(@accepted_friendship)
      expect(Friendship.accepted).not_to include(@pending_friendship, @rejected_friendship)
    end
    
    it 'returns rejected friendships' do
      expect(Friendship.rejected).to include(@rejected_friendship)
      expect(Friendship.rejected).not_to include(@pending_friendship, @accepted_friendship)
    end
  end
end
