class AddStripeIdToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :stripe_customer_id, :string
  end
end
