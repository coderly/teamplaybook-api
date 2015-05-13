class Plan < ActiveRecord::Base

  after_create :assign_stripe_plan
  after_update :update_stripe_plan

  def is_paid?
    amount > 0
  end

  def self.default_plan
    find_by_slug(Settings.billing.default_plan)
  end

  def self.find_by_slug(slug)
    find_by slug: slug
  end

  def self.find_or_initialize_by_slug(slug:)
    Plan.where(slug: slug).first_or_initialize
  end

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

    stripe_plan.save
  end

  def plan_data_changed?
    amount_changed? || interval_changed? || name_changed? || trial_period_days_changed?
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