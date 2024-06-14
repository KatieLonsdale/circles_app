FactoryBot.define do
  factory :circle do
    name { Faker::Company.industry }
    description { Faker::Company.bs }
    created_at { Time.now }
    updated_at { Time.now }

    association :user, factory: :user
  end
end
