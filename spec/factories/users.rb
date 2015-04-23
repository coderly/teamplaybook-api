FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "user #{n}" }
    sequence(:email) { |n| "email_#{n}@test.com" }
    password "password"
    password_confirmation "password"
  end
end
