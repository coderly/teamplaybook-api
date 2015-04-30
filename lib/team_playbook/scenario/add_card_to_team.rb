module TeamPlaybook
  module Scenario
    class AddCardToTeam
      def call(team, card_token)
        create_card_for_stripe_customer(stripe_customer_for_team(team), card_token)
      end

      private

      def create_card_for_stripe_customer(stripe_customer, card_token)
        stripe_customer.sources.create(:source => card_token)
      end

      # Yes, this is a duplication with ChangePlanForTeam methods
      # all of these will eventually have to go to a class.
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

    end
  end
end