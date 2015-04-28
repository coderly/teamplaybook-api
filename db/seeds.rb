require 'team_playbook/scenario/create_or_update_plan'
Settings.billing.plans.each do |plan_info|
  plan = TeamPlaybook::Scenario::CreateOrUpdatePlan.new.call(plan_info)
  puts "#{plan.name} is created"
end