module TeamPlaybook
  module Scenario
    class CreateOrUpdatePlan
      def call(plan_info)
        plan = Plan.where(slug: plan_info.slug).first_or_initialize
        plan.name = plan_info.name
        plan.amount = plan_info.amount
        plan.interval = plan_info.interval
        plan.trial_period_days = plan_info.trial_period_days

        plan.save!
        plan
      end
    end
  end
end