class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products, :primary_key => :product_id do |t|
      t.string :number
      t.string :name
      t.timestamps null: false
    end
  end
end
