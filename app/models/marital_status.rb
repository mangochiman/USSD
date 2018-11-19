class MaritalStatus < ActiveRecord::Base
  self.table_name = "marital_statuses"
  self.primary_key = "marital_status_id"
end
