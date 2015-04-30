class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :slug, null: false
      t.integer :amount, default: 0, null: false
      t.string :interval,  default: 'month', null: false
      t.string :stripe_id
      t.string :name, null: false
      t.integer :trial_period_days, default: 0, null: false
      t.timestamps null: false
    end
  end
end