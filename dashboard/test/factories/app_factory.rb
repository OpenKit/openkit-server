FactoryGirl.define do
  factory :app do
    sequence(:name) { |x| "test_game#{x}" }
  end
end
