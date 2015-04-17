FactoryGirl.define do

  factory :organization do |answer|
    sequence(:name) { |n| "Organization #{n}" }
    sequence(:subdomain) { |n| "organization#{n}" }
  end

end