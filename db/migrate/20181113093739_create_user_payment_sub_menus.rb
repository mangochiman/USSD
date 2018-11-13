class CreateUserPaymentSubMenus < ActiveRecord::Migration
  def change
    create_table :user_payment_sub_menus, :primary_key => :user_payment_sub_menu_id do |t|
      t.string :user_id
      t.integer :payment_menu_id
      t.integer :payment_menu_sub_id
      t.timestamps null: false
    end
  end
end
