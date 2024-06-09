FactoryBot.define do
  factory :post do
    circle_id { "" }
    created_at { "2024-06-09 12:00:56" }
    updated_at { "2024-06-09 12:00:56" }
    caption { "MyString" }
    user_id { 1 }
  end
end
