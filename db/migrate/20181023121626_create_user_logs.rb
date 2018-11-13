class CreateUserLogs < ActiveRecord::Migration
  def change
    create_table :user_logs, :primary_key => :user_log_id do |t|
      t.string :user_id
      t.string :phone_number
      t.string :gender
      t.string :name
      t.string :district
      t.string :product
      t.string :payment
      t.timestamps null: false
    end
  end
end
