FactoryGirl.define do
  sequence(:email) { |n| "email_#{n}@test.com" }

  factory :team_membership do
    email
  end

  trait :with_user do
    after :create do |team_membership, evaluator|
      user = FactoryGirl.create(:user)
      team_membership.user = user;
      team_membership.email = user.email;
      team_membership.save!
    end
  end
end