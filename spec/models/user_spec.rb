require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'relationships' do
    it { should have_many :circles }
    it { should have_many :circle_members }
    it { should have_many :friendships }
    it { should have_many :friends }
    it { should have_many :pending_friends }
    it { should have_many :rejected_friends }
    it { should have_many :inverse_friendships }
    it { should have_many :inverse_friends }
    it { should have_many :pending_inverse_friends }
    it { should have_many :rejected_inverse_friends }
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
    
    describe 'friendship methods' do
      let(:user) { create(:user) }
      let(:friend) { create(:user) }
      let(:pending_friend) { create(:user) }
      let(:inverse_friend) { create(:user) }
      
      before do
        # Create a direct friendship (user -> friend)
        create(:friendship, user: user, friend: friend, status: :accepted)
        
        # Create a pending friendship (user -> pending_friend)
        create(:friendship, user: user, friend: pending_friend, status: :pending)
        
        # Create an inverse friendship (inverse_friend -> user)
        create(:friendship, user: inverse_friend, friend: user, status: :accepted)
      end
      
      describe '#all_friends' do
        it 'returns all accepted friends from both directions' do
          user2 = create(:user)
          create(:friendship, user: user2, friend: user, status: :accepted)
          expect(user.all_friends).to include(friend, inverse_friend)
          expect(user.all_friends.count).to eq(3)
        end
      end
      
      describe '#all_pending_friends' do
        it 'returns all pending friends from both directions' do
          # Create a pending inverse friendship
          pending_inverse = create(:user)
          create(:friendship, user: pending_inverse, friend: user, status: :pending)
          
          expect(user.all_pending_friends).to include(pending_friend, pending_inverse)
          expect(user.all_pending_friends.count).to eq(2)
        end
      end
      
      describe '#friend_request' do
        it 'creates a new pending friendship' do
          new_friend = create(:user)
          
          expect {
            user.friend_request(new_friend)
          }.to change(Friendship, :count).by(1)
          
          friendship = Friendship.last
          expect(friendship.user).to eq(user)
          expect(friendship.friend).to eq(new_friend)
          expect(friendship.status).to eq('pending')
        end
      end
      
      describe '#accept_friend_request' do
        it 'accepts a pending friend request' do
          requester = create(:user)
          create(:friendship, user: requester, friend: user, status: :pending)
          
          user.accept_friend_request(requester)
          
          friendship = Friendship.find_by(user: requester, friend: user)
          expect(friendship.status).to eq('accepted')
        end
        
        it 'does nothing if no request exists' do
          non_requester = create(:user)
          
          expect {
            user.accept_friend_request(non_requester)
          }.not_to change { Friendship.count }
        end
      end
      
      describe '#reject_friend_request' do
        it 'rejects a pending friend request' do
          requester = create(:user)
          create(:friendship, user: requester, friend: user, status: :pending)
          
          user.reject_friend_request(requester)
          
          friendship = Friendship.find_by(user: requester, friend: user)
          expect(friendship.status).to eq('rejected')
        end
        
        it 'does nothing if no request exists' do
          non_requester = create(:user)
          
          expect {
            user.reject_friend_request(non_requester)
          }.not_to change { Friendship.count }
        end
      end
      
      describe '#remove_friend' do
        it 'removes a direct friendship' do
          expect {
            user.remove_friend(friend)
          }.to change(Friendship, :count).by(-1)
          
          expect(Friendship.find_by(user: user, friend: friend)).to be_nil
        end
        
        it 'removes an inverse friendship' do
          expect {
            user.remove_friend(inverse_friend)
          }.to change(Friendship, :count).by(-1)
          
          expect(Friendship.find_by(user: inverse_friend, friend: user)).to be_nil
        end
        
        it 'does nothing if no friendship exists' do
          non_friend = create(:user)
          
          expect {
            user.remove_friend(non_friend)
          }.not_to change { Friendship.count }
        end
      end
      
      describe '#friends_with?' do
        it 'returns true if users are direct friends' do
          expect(user.friends_with?(friend)).to be true
        end
        
        it 'returns true if users are inverse friends' do
          expect(user.friends_with?(inverse_friend)).to be true
        end
        
        it 'returns false if users are not friends' do
          non_friend = create(:user)
          expect(user.friends_with?(non_friend)).to be false
        end
        
        it 'returns false if friendship is pending' do
          expect(user.friends_with?(pending_friend)).to be false
        end
      end
      
      #todo: not sure if we will use this, delete if not 3/7
      describe '#pending_friend_request_from?' do
        it 'returns true if there is a pending request from the user' do
          requester = create(:user)
          create(:friendship, user: requester, friend: user, status: :pending)
          
          expect(user.pending_friend_request_from?(requester)).to be true
        end
        
        it 'returns false if there is no pending request from the user' do
          non_requester = create(:user)
          expect(user.pending_friend_request_from?(non_requester)).to be false
        end
      end
      
      #todo: not sure if we will use this, delete if not 3/7
      describe '#pending_friend_request_to?' do
        it 'returns true if there is a pending request to the user' do
          expect(user.pending_friend_request_to?(pending_friend)).to be true
        end
        
        it 'returns false if there is no pending request to the user' do
          non_pending = create(:user)
          expect(user.pending_friend_request_to?(non_pending)).to be false
        end
      end
    end
  end

  describe "class methods" do
    describe ".search" do
      before do
        User.destroy_all
        @user1 = create(:user, display_name: "John Smith")
        @user2 = create(:user, display_name: "Johnny Walker")
        @user3 = create(:user, display_name: "Jane Doe")
        @user4 = create(:user, display_name: "Robert Johnson")
      end

      it "returns users whose display_name contains the search query" do
        results = User.search("John")
        expect(results).to include(@user1, @user2, @user4)
        expect(results.pluck(:id)).not_to include(@user3.id)
      end

      it "is case insensitive" do
        results = User.search("john")
        expect(results).to include(@user1, @user2, @user4)
        expect(results.pluck(:id)).not_to include(@user3.id)
      end

      it "returns nil if query is blank" do
        expect(User.search("")).to be_nil
        expect(User.search(nil)).to be_nil
      end

      it "returns partial matches" do
        results = User.search("oh")
        expect(results).to include(@user1, @user2, @user4)
        expect(results.pluck(:id)).not_to include(@user3.id)
      end
    end
  end
end

