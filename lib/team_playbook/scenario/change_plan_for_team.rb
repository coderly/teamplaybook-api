require 'errors/credit_card_required_error'
module TeamPlaybook
  module Scenario
    class ChangePlanForTeam
      def call(team, plan)
        create_plan_subscription_for_team(team, plan)
        create_stripe_subscription_for_team(team)
      end

      private

      def create_plan_subscription_for_team(team, plan)
        team.plan = plan
        team.save
      end

      def create_stripe_subscription_for_team(team)
        plan = team.plan
        stripe_customer = stripe_customer_for_team(team)

        raise CreditCardRequiredError if plan.is_paid? && customer_has_no_cards?(stripe_customer)

        subscription = stripe_customer_for_team(team).subscriptions.create(:plan => plan.stripe_id)
        team.subscription.update_attribute :stripe_subscription_id, subscription.id
      end

      def stripe_customer_for_team(team)
        return create_stripe_customer_for_team(team) unless team_has_stripe_customer?(team)
        retrieve_stripe_customer_for_team(team)
      end

      def create_stripe_customer_for_team(team)
        customer = Stripe::Customer.create(description: "Customer for #{team.name}")
        team.update_attribute :stripe_customer_id, customer.id
        customer
      end

      def team_has_stripe_customer?(team)
        team.stripe_customer_id.present?
      end

      def retrieve_stripe_customer_for_team(team)
        Stripe::Customer.retrieve(team.stripe_customer_id)
      end

      def customer_has_no_cards?(stripe_customer)
        stripe_customer.sources.count < 1
      end
    end
  end
end