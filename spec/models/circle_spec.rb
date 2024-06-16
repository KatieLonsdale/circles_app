require 'rails_helper'

RSpec.describe Circle, type: :model do
  describe 'relationships' do
    it { should have_many :posts }
    it { should have_many :circle_members }
    it { should belong_to :user }
    it { should have_many(:comments).through(:posts) }
    it { should have_many(:post_user_reactions).through(:posts) }
    it { should have_many(:content).through(:posts) }
  end

  describe 'validations' do
    it { should validate_presence_of :name}
    it { should validate_presence_of :user_id}
    it { should validate_presence_of :description}
  end

  describe 'instance methods' do
    describe 'verify_member' do
      before(:all) do
        create_list(:user, 2)
        create_list(:circle, 2)
      end
      it 'returns true if user is a member' do
        user = create(:user)
        member_circle = Circle.first
        non_member_circle = Circle.last
        # add new user to one circle, but not the other
        create(:circle_member, user_id: user.id, circle_id: member_circle.id)

        expect(member_circle.verify_member(user.id)).to eq(true)
        expect(non_member_circle.verify_member(user.id)).to eq(false)
      end

      it 'returns true if user is an owner' do
        owner_circle = Circle.first
        owner = owner_circle.user
        other_owner = create(:user)
        non_owner_circle = create(:circle, user_id: other_owner.id)

        expect(owner_circle.verify_member(owner.id)).to eq(true)
        expect(non_owner_circle.verify_member(owner.id)).to eq(false)
      end
    end

    describe 'owner?' do
      it 'returns true if user is the owner' do
        create_list(:user, 2)
        owner = User.first
        member = User.last
        circle = create(:circle, user_id: owner.id)
        create(:circle_member, user_id: member.id, circle_id: circle.id)

        expect(circle.owner?(owner.id)).to eq(true)
        expect(circle.owner?(member.id)).to eq(false)
      end
    end
  end
end