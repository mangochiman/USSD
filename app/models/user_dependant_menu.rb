class UserDependantMenu < ActiveRecord::Base
  self.table_name = "user_dependant_menus"
  self.primary_key = "user_dependant_menu_id"

  belongs_to :dependant_menu, :foreign_key => :dependant_menu_id
end
