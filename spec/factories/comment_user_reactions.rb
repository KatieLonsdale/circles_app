FactoryBot.define do
  factory :comment_user_reaction do
    comment_id { nil }
    user_id { 1 }
    reaction_id { 1 }
  end
end
