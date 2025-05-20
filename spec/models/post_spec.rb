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

  describe 'instance methods' do
    describe '#owner_or_author?' do
      it 'returns true if user_id matches author_id or the circle owner id' do
        users = create_list(:user, 3)
        post = create(:post)
        circle = post.circle
        # author is authorized
        author = users[0]
        post.update(author_id: author.id)
        # owner is authorized
        owner = users[1]
        circle.update(user_id: owner.id)

        expect(post.owner_or_author?(author.id)).to eq(true)
        expect(post.owner_or_author?(owner.id)).to eq(true)
        expect(post.owner_or_author?(users[2].id)).to eq(false)
      end
    end

    describe 'author_display_name' do
      it 'should return the display name of the author' do
        users = create_list(:user, 2)
        post_1 = create(:post, author_id: users[0].id)
        post_2 = create(:post, author_id: users[1].id)
        post_3 = create(:post, author_id: users[1].id)

        expect(post_1.author_display_name).to eq(users[0].display_name)
        expect(post_2.author_display_name).to eq(users[1].display_name)
        expect(post_3.author_display_name).to eq(users[1].display_name)
      end
    end
    
    describe '#top_level_comments' do
      it 'returns only comments without a parent comment' do
        user = create(:user)
        post = create(:post, author_id: user.id)
        
        # Create top level comments
        top_comment1 = create(:comment, post: post, parent_comment_id: nil, author_id: user.id)
        top_comment2 = create(:comment, post: post, parent_comment_id: nil, author_id: user.id)
        
        # Create reply comments with parent_comment_id
        reply1 = create(:comment, post: post, parent_comment_id: top_comment1.id, author_id: user.id)
        reply2 = create(:comment, post: post, parent_comment_id: top_comment2.id, author_id: user.id)
        
        top_level_comments = post.top_level_comments
        
        expect(top_level_comments).to include(top_comment1)
        expect(top_level_comments).to include(top_comment2)
        expect(top_level_comments).not_to include(reply1)
        expect(top_level_comments).not_to include(reply2)
        expect(top_level_comments.count).to eq(2)
      end
    end
  end
end
