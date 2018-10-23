class SeenStatus < ActiveRecord::Base
  self.table_name = "seen_statuses"
  self.primary_key = "seen_status_id"
end
