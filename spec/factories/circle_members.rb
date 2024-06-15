FactoryBot.define do
  factory :circle_member do
    created_at { Time.now }
    updated_at { Time.now }

    association :user, factory: :user
    association :circle, factory: :circle
  end
end
