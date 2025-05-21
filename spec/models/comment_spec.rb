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

  describe 'instance methods' do
    describe 'author_display_name' do
      it 'should return the display name of the author' do
        users = create_list(:user, 2)
        posts = create_list(:post, 2)
        comment_1 = create(:comment, post_id: posts[0].id, author_id: users[0].id)
        comment_2 = create(:comment, post_id: posts[1].id, author_id: users[1].id)
        comment_3 = create(:comment, post_id: posts[0].id, author_id: users[1].id)

        expect(comment_1.author_display_name).to eq(users[0].display_name)
        expect(comment_2.author_display_name).to eq(users[1].display_name)
        expect(comment_3.author_display_name).to eq(users[1].display_name)
      end
    end
    
    describe 'replies' do
      it 'returns all comments where parent_comment_id matches the comment id' do
        user = create(:user)
        post = create(:post, author_id: user.id)
        
        # Create parent comment
        parent_comment = create(:comment, post: post, parent_comment_id: nil, author_id: user.id)
        
        # Create replies to the parent comment
        reply1 = create(:comment, post: post, parent_comment_id: parent_comment.id, author_id: user.id)
        reply2 = create(:comment, post: post, parent_comment_id: parent_comment.id, author_id: user.id)
        
        # Create another comment with its own replies
        other_comment = create(:comment, post: post, parent_comment_id: nil, author_id: user.id)
        other_reply = create(:comment, post: post, parent_comment_id: other_comment.id, author_id: user.id)
        
        # Test the replies method
        replies = parent_comment.replies
        
        expect(replies).to include(reply1)
        expect(replies).to include(reply2)
        expect(replies).not_to include(other_reply)
        expect(replies.count).to eq(2)
      end
      
      it 'returns an empty collection when a comment has no replies' do
        user = create(:user)
        post = create(:post, author_id: user.id)
        
        # Create a comment with no replies
        comment = create(:comment, post: post, parent_comment_id: nil, author_id: user.id)
        
        replies = comment.replies
        
        expect(replies).to be_empty
        expect(replies.count).to eq(0)
      end
      
      it 'works with nested replies' do
        user = create(:user)
        post = create(:post, author_id: user.id)
        
        # Create parent comment
        parent_comment = create(:comment, post: post, parent_comment_id: nil, author_id: user.id)
        
        # Create a reply to the parent comment
        reply = create(:comment, post: post, parent_comment_id: parent_comment.id, author_id: user.id)
        
        # Create a reply to the reply
        nested_reply = create(:comment, post: post, parent_comment_id: reply.id, author_id: user.id)
        
        # Test the replies method for both parent and reply
        parent_replies = parent_comment.replies
        reply_replies = reply.replies
        
        expect(parent_replies).to include(reply)
        expect(parent_replies).not_to include(nested_reply)
        expect(parent_replies.count).to eq(1)
        
        expect(reply_replies).to include(nested_reply)
        expect(reply_replies.count).to eq(1)
      end
    end
  end
end