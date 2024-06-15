FactoryBot.define do
  factory :content do
    video_url { nil }
    image_url { nil }

    after(:build) do |content|
      case rand(3)
      when 0
        content.video_url = Faker::Internet.url
      when 1
        content.image_url = Faker::Internet.url
      end
    end

    association :post, factory: :post
  end
end
