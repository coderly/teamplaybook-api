class AddStatusFieldToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :status, :integer, default: 1
  end
end
