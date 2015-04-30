class ChangeStripeIdToStripeSubscriptionId < ActiveRecord::Migration
  def change
    rename_column :subscriptions, :stripe_id, :stripe_subscription_id
  end
end
