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
  end
end