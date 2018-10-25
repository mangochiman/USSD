class MainMenu < ActiveRecord::Base
  self.table_name = "main_menus"
  self.primary_key = "main_menu_id"

  has_many :main_sub_menus
end
