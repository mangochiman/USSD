class MainSubMenu < ActiveRecord::Base
  self.table_name = "main_sub_menus"
  self.primary_key = "main_sub_menu_id"

  belongs_to :main_menu, :foreign_key => :main_menu_id
end
