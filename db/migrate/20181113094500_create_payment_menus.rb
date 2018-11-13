class CreatePaymentMenus < ActiveRecord::Migration
  def change
    create_table :payment_menus, :primary_key => :payment_menu_id do |t|
      t.integer :menu_number
      t.string :name
      t.timestamps null: false
    end
  end
end
