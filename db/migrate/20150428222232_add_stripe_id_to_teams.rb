class AddStripeIdToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :stripe_id, :string
  end
end
