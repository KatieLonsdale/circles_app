FactoryBot.define do
  factory :comment do
    parent_comment_id { nil }
    author_id { User.all.sample.id }
    comment_text { Faker::Lorem.sentence }
    created_at { Time.now }
    updated_at { Time.now }

    association :post, factory: :post
  end
end
