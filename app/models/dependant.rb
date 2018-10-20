class Dependant < ActiveRecord::Base
  self.table_name = "dependants"
  self.primary_key = "dependant_id"
end
