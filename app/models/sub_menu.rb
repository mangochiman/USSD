class SubMenu < ActiveRecord::Base
  self.table_name = "sub_menus"
  self.primary_key = "sub_menu_id"

  belongs_to :menu, :foreign_key => :menu_id
end
