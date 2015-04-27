FactoryGirl.define do
  factory :team do |answer|
    sequence(:name) { |n| "Team #{n}" }
    sequence(:subdomain) { |n| "team#{n}" }
  end
end