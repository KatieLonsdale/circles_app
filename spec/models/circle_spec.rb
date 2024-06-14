require 'rails_helper'

RSpec.describe Circle, type: :model do
  describe 'relationships' do
    it { should have_many :posts }
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

  describe 'add_member' do
    it 'adds a user to the circle' do
      User.destroy_all
      # create 3 users and 3 circles
      users = create_list(:user, 3)
      circles = create_list(:circle, 3)
      
      # assign all users to a circle
      member_circle = Circle.first
      
      # create circle that user should not appear in
      non_member_circle = Circle.second
      
      # create new user to add to circle members
      user = create(:user)

      member_circle.add_member(user.id)

      member_circle_members = JSON.parse(member_circle.members)
      non_member_circle_members = JSON.parse(non_member_circle.members)
      new_member = {"id" => user.id}

      expect(member_circle_members).to include(new_member)
      expect(non_member_circle_members).to_not include(new_member)
    end
  end
end