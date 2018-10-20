class Member < ActiveRecord::Base
  self.table_name = "members"
  self.primary_key = "member_id"
end
