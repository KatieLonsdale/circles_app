FactoryBot.define do
  factory :notification do
    message { Faker::Lorem.sentence }
    read { false }
    action { ["post_created", "comment_created", "friend_request", "circle_invitation"].sample }
    
    association :user
    # Use transient attribute to set circle_id from a circle
    transient do
      circle { create(:circle) }
    end
    
    after(:build) do |notification, evaluator|
      notification.circle_id = evaluator.circle&.id unless evaluator.circle.nil?
    end
    
    # By default, create notifications for posts
    association :notifiable, factory: :post
    
    # Allow creating notifications for different notifiable types
    trait :for_comment do
      association :notifiable, factory: :comment
    end
  end
end
