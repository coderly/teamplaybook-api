class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.string :body
      t.boolean :root_node, default: false
      t.integer :parent_id
      t.integer :team_id
      t.timestamps null: false
    end
  end
end