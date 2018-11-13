class UserPaymentSubMenu < ActiveRecord::Base
  self.table_name = "user_payment_sub_menus"
  self.primary_key = "user_payment_sub_menu_id"

  belongs_to :main_sub_menu, :foreign_key => :payment_menu_sub_id, :primary_key => :main_sub_menu_id
end
