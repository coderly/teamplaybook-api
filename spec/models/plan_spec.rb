require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe "stripe plan" do
    it "should create an stripe plan when the plan gets created" do
      plan = create(:plan, slug: 'test_plan', amount: 50)
      
      expect(plan.stripe_id).not_to be_nil
    end

    it "should create an stripe plan with the correct data" do
      plan = create(:plan, slug: 'test_plan', amount: 50, name: "Awesome test plan", trial_period_days: 15)
      stripe_plan = Stripe::Plan.retrieve(plan.stripe_id)
      
      expect(stripe_plan.name).to eq "Awesome test plan"
      expect(stripe_plan.amount).to eq 50
      expect(stripe_plan.trial_period_days).to eq 15
      expect(stripe_plan.id).to eq 'test_plan'
    end


    it "should update the stripe plan" do
      plan = create(:plan, slug: 'test_plan', amount: 50, name: "Awesome test plan", trial_period_days: 15)
      stripe_plan = Stripe::Plan.retrieve(plan.stripe_id)
      
      expect(stripe_plan.name).to eq "Awesome test plan"
      expect(stripe_plan.amount).to eq 50
      expect(stripe_plan.trial_period_days).to eq 15
      expect(stripe_plan.id).to eq 'test_plan'

      plan.update_attribute :amount, 65
      stripe_plan = Stripe::Plan.retrieve(plan.stripe_id)
      
      expect(stripe_plan.name).to eq "Awesome test plan"
      expect(stripe_plan.amount).to eq 65
    end
  end
end