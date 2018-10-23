class UserLog < ActiveRecord::Base
  self.table_name = "user_logs"
  self.primary_key = "user_log_id"
end
