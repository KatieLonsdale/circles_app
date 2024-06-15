FactoryBot.define do
  factory :post do
    created_at { Time.now }
    updated_at { Time.now }
    caption { Faker::Lorem.sentence(word_count: 5) }
    author_id { User.all.sample.id }

    association :circle, factory: :circle
  end
end
