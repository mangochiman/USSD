class UserClaimsSubMenu < ActiveRecord::Base
  self.table_name = "user_claims_sub_menus"
  self.primary_key = "user_claim_sub_menu_id"

  belongs_to :main_sub_menu, :foreign_key => :claim_menu_sub_id, :primary_key => :main_sub_menu_id
end
