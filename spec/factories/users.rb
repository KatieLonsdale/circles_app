FactoryBot.define do
  factory :user do
    id { Faker::Number.number(digits: 5)}
    email { Faker::Internet.email }
    password { BCrypt::Password.create('password') }
    display_name { Faker::Name.name }
    notification_frequency { %w[live hourly daily].sample }
    created_at { Time.now }
    updated_at { Time.now }
    notifications_token { Faker::Alphanumeric.alphanumeric(number: 20) }
  end
end
