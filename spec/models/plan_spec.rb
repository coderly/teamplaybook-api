require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe "stripe plan" do
    it "should create an stripe plan when the plan gets created" do
      plan = create(:plan, slug: 'test_plan')
      expect(plan.stripe_id).not_to be_nil
    end
  end
end