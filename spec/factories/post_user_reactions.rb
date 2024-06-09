FactoryBot.define do
  factory :post_user_reaction do
    post { nil }
    user_id { 1 }
    reaction_id { 1 }
  end
end
