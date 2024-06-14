FactoryBot.define do
  factory :circle do
    name { Faker::Company.industry }
    description { Faker::Company.bs }
    created_at { Time.now }
    updated_at { Time.now }

    association :user, factory: :user

    transient do
      members_count { 3 }  # Default number of members to create
    end

    after(:build) do |circle, evaluator|
      members = FactoryBot.create_list(:user, evaluator.members_count)
      members_array = members.map { |member| { id: member.id } }
      circle.members = members_array.to_json
    end

  end
end
