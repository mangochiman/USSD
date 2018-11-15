class CreateMainUserLogs < ActiveRecord::Migration
  def change
    create_table :main_user_logs, :primary_key => :main_user_log_id do |t|
      t.string :user_id
      t.string :phone_number
      t.string :gender
      t.string :name
      t.string :district
      t.string :dependant
      t.string :payment
      t.string :payment_menu
      t.string :airtel_money
      t.string :tnm_mpamba
      t.timestamps null: false
    end
  end
end
