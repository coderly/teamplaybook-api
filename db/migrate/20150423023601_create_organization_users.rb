class CreateOrganizationUsers < ActiveRecord::Migration
  def change
    create_table :organization_users do |t|
      t.string :email, null: false
      t.integer :organization_id, null: false
      t.integer :user_id
      t.timestamps null: false
    end
  end
end