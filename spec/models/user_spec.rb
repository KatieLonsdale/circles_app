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
    describe 'get_all_circles' do
      it 'gets all circles that a user belongs to or owns' do
        create_list(:circle, 10)
        # assign a new user to 3 circles
        user = create(:user)
        not_owned_circles = Circle.all.sample(3)
        not_owned_circles.each do |circle|
          create(:circle_member, user_id: user.id, circle_id: circle.id)
        end
        # create circles that user owns
        owned_circles = create_list(:circle, 2, user_id: user.id)

        all_circles = owned_circles + not_owned_circles

        test_result_circles = user.get_all_circles

        expect(test_result_circles.sort).to eq(all_circles.sort)
      end
    end

    describe 'get_member_circle_circles' do
      it 'gets all circles that a user is a member of' do
        create_list(:circle, 10)
        # assign a new user to 3 circles
        user = create(:user)
        user_circles = Circle.all.sample(5)
        user_circles.each do |circle|
          create(:circle_member, user_id: user.id, circle_id: circle.id)
        end

        test_result_circles = user.get_circle_member_circles
        expect(test_result_circles.sort).to eq(user_circles.sort)
      end
    end

    describe 'get_newsfeed' do
      it 'returns all posts from circles that a user belongs to' do
        circles = create_list(:circle, 3)
        user_1 = create(:user)
        user_2 = create(:user)
        user_3 = create(:user)
        # user 1 belongs to all circles
        circles.each do |circle|
          create(:circle_member, user_id: user_1.id, circle_id: circle.id)
          create_list(:post, 3, circle_id: circle.id)
        end
        # user 2 belongs to one circle
        create(:circle_member, user_id: user_2.id, circle_id: circles[0].id)

        user_1_posts = user_1.get_newsfeed
        user_2_posts = user_2.get_newsfeed
        user_3_posts = user_3.get_newsfeed

        expect(user_1_posts.count).to eq(9)
        expect(user_2_posts.count).to eq(3)
        expect(user_3_posts.count).to eq(0)

        expect(user_1_posts.first).to be_an_instance_of(Post)
      end
    end
  end
end

