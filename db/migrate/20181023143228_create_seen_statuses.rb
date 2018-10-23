class CreateSeenStatuses < ActiveRecord::Migration
  def change
    create_table :seen_statuses, :primary_key => :seen_status_id do |t|
      t.string :user_id
      t.boolean :phone_number, default: false
      t.boolean :gender, default: false
      t.boolean :name, default: false
      t.boolean :district, default: false
      t.timestamps null: false
    end
  end
end
