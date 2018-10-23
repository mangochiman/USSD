class Menu < ActiveRecord::Base
  self.table_name = "menus"
  self.primary_key = "menu_id"

  has_many :sub_menus
end
