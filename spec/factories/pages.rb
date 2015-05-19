FactoryGirl.define do
  factory :page do
    sequence(:title) { |n| "Test Page #{n}" }
    body "Test body"
    root false
  end
end