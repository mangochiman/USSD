class UserDependantSubMenu < ActiveRecord::Base
  self.table_name = "user_dependant_sub_menus"
  self.primary_key = "user_dependant_sub_menu_id"

  belongs_to :main_sub_menu, :foreign_key => :dependant_menu_sub_id, :primary_key => :main_sub_menu_id

end
