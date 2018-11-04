class AddResetToMainSeenStatuses < ActiveRecord::Migration
  def change
    add_column :main_seen_statuses, :reset, :boolean, :default => false
    #change_column :main_seen_statuses, :reset, :boolean, :default => false
  end
end
