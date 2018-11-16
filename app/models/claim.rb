class Claim < ActiveRecord::Base
  self.table_name = "claims"
  self.primary_key = "claim_id"
end
