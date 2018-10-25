class MainUserMenu < ActiveRecord::Base
  self.table_name = "main_user_menus"
  self.primary_key = "main_user_menu_id"

  belongs_to :main_menu, :foreign_key => :main_menu_id
end
