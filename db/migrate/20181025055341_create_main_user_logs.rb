class CreateMainUserLogs < ActiveRecord::Migration
  def change
    create_table :main_user_logs, :primary_key => :main_user_log_id do |t|
      t.string :user_id
      t.string :phone_number
      t.string :gender
      t.string :title
      t.string :initials
      t.string :year_of_birth
      t.string :month_of_birth
      t.string :day_of_birth
      t.string :date_of_birth
      t.string :identification_type
      t.string :identification_number
      t.string :country_of_birth
      t.string :nationality
      t.string :first_name
      t.string :surname
      t.string :previous_surname
      t.string :marital_status
      t.string :name
      t.string :district
      t.string :dependant
      t.string :product
      t.string :payment
      t.string :payment_menu
      t.string :airtel_money
      t.string :tnm_mpamba
      t.string :claim_description
      t.timestamps null: false
    end
  end
end
