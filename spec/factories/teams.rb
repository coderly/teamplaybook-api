FactoryGirl.define do
  factory :team do |answer|
    sequence(:name) { |n| "Team #{n}" }
    sequence(:subdomain) { |n| "team#{n}" }
  end

  trait :with_users do
    ignore do
      number_of_users 1
    end

    after :create do |team, evaluator|
      users = FactoryGirl.build_list :user, evaluator.number_of_users
      users.each do |user|
        team_membership = create(:team_membership, user: user, team: team, email: user.email)
        user.save!
      end
    end
  end
end