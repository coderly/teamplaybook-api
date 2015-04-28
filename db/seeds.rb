require 'team_playbook/scneario/create_or_update_plan'
Settings.billing.plans.each do |plan_info|
  TeamPlaybook::Scenario::CreateOrUpdatePlan.new.call(plan_info)
end