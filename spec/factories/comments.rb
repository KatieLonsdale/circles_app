FactoryBot.define do
  factory :comment do
    parent_comment_id { nil }
    author_id { User.all.sample.id }
    comment_text { Faker::Lorem.sentence }
    created_at { Time.now }
    updated_at { Time.now }

    after(:build) do |comment|
      case rand(2)
      when 0
        if Comment.count > 0
          comment.parent_comment_id = Comment.all.sample.id
        else
          comment.parent_comment_id = nil
        end
      end
    end

    association :post, factory: :post
  end
end
