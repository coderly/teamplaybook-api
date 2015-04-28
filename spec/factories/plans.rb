FactoryGirl.define do
  factory :plan do
    amount 20
    interval "month"
    trial_period_days 30
    sequence(:name) { |n| "Test Plan #{n}" }
    sequence(:slug) { |n| "test_plan_#{n}" }
  end
end