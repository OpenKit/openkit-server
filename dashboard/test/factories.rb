FactoryGirl.define do

  factory :developer do
    sequence(:email) { |n| "email#{n}@example.com" }
    password 'password'
    password_confirmation { password }
  end

  factory :app do
    developer
    sequence(:name) { |x| "test_game#{x}" }
  end

  factory :leaderboard do
    app
    sequence(:name) { |n| "leaderboard#{n}" }
    trait :high_value do
      sort_type 'HighValue'
    end
    trait :low_value do
      sort_type 'LowValue'
    end
  end

  factory :achievement do
    app
    sequence(:name) { |n| "achievement#{n}" }
    desc "Get x foos and receive a bar"
    points
  end
end
