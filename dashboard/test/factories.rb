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
    desc "Reach a goal of X and get Y points"
    goal 100
    points 5
  end

  factory :user do
    developer
    sequence(:nick)      { |n| "Fake #{n}" }
    sequence(:custom_id) { |n| n.to_s }
  end

  factory :subscription do
    user
    app
  end
end
