class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :team_id
      t.integer :stripe_id
      t.integer :plan_id
      t.timestamps null: false
    end
  end
end