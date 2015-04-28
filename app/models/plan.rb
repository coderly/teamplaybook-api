class Plan < ActiveRecord::Base

  after_create :assign_stripe_plan
  after_update :update_stripe_plan

  private

  def assign_stripe_plan
    stripe_plan = create_stripe_plan
    update_column :stripe_id, stripe_plan.id
  end

  def update_stripe_plan
    return unless plan_data_changed?
    stripe_plan = fetch_stripe_plan
    stripe_plan.amount = amount
    stripe_plan.interval = interval
    stripe_plan.name = name
    stripe_plan.trial_period_days = trial_period_days
    stripe_plan.id = slug

    stripe_plan.save
    update_column :stripe_id, stripe_plan.id
  end

  def plan_data_changed?
    amount_changed? || interval_changed? || name_changed? || trial_period_days_changed? || slug_changed?
  end

  def fetch_stripe_plan
    return null unless stripe_id.present?
    Stripe::Plan.retrieve(stripe_id)
  end

  def create_stripe_plan
    Stripe::Plan.create(
      amount: amount,
      interval: interval,
      name: name,
      currency: 'usd',
      trial_period_days: trial_period_days,
      id: slug
    )
  end

end
