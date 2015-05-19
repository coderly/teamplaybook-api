class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.string :body
      t.string :root, default: true
      t.integer :parent_id
      t.timestamps null: false
    end
  end
end
