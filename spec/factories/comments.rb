FactoryBot.define do
  factory :comment do
    post_id { nil }
    parent_comment_id { 1 }
    user_id { 1 }
  end
end
