class CreateUserPaymentMenus < ActiveRecord::Migration
  def change
    create_table :user_payment_menus, :primary_key => :user_payment_menu_id do |t|
      t.string :user_id
      t.integer :payment_menu_id
      t.timestamps null: false
    end
  end
end
