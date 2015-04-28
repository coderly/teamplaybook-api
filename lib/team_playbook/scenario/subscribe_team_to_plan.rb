module TeamPlaybook
  module Scenario
    class SubscribeTeamToPlan
      def call(team, plan_slug)
        create_plan_subscription_for_team(team, plan_slug)
        create_stripe_subscription_for_team(team)
      end

      private

      def create_plan_subscription_for_team(team, plan_slug)
        team.plan = fetch_plan(plan_slug)
        team.save
      end

      def create_stripe_subscription_for_team(team)
        plan = team.plan
        subscription = stripe_customer_for_team(team).subscriptions.create(:plan => plan.stripe_id)
        team.subscription.update_attribute :stripe_id, subscription.id
      end

      def stripe_customer_for_team(team)
        return create_stripe_customer_for_team(team) unless team.has_stripe_customer?
        team.stripe_customer
      end

      def create_stripe_customer_for_team(team)
        customer = Stripe::Customer.create(description: "Customer for #{team.name}")
        team.update_attribute :stripe_id, customer.id
        customer
      end

      def fetch_plan(plan_slug)
        return default_plan if plan_slug.blank?
        Plan.find_by! slug: plan_slug
      end

      def default_plan
        Plan.find_by slug: Settings.billing.default_plan
      end

    end
  end
end