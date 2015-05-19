FactoryGirl.define do
  factory :page do
    sequence(:title) { |n| "Test Page #{n}" }
    body "Test body"
    root_node false
  end
end