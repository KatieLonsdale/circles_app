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
  end
end
