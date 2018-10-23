class UserMenu < ActiveRecord::Base
  self.table_name = "user_menus"
  self.primary_key = "user_menu_id"
end
