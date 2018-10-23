class UserMenu < ActiveRecord::Base
  self.table_name = "user_menus"
  self.primary_key = "user_menu_id"

  belongs_to :menu, :foreign_key => :menu_id
end
