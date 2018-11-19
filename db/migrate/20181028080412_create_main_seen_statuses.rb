class CreateMainSeenStatuses < ActiveRecord::Migration
  def change
    create_table :main_seen_statuses, :primary_key => :main_seen_status_id do |t|
      t.string :user_id
      t.boolean :phone_number, default: false
      t.boolean :gender, default: false
      t.boolean :title, default: false
      t.boolean :initials, default: false
      t.boolean :year_of_birth, default: false
      t.boolean :month_of_birth, default: false
      t.boolean :day_of_birth, default: false
      t.boolean :identification_type, default: false
      t.boolean :identification_number, default: false
      t.boolean :country_of_birth, default: false
      t.boolean :nationality, default: false
      t.boolean :first_name, default: false
      t.boolean :surname, default: false
      t.boolean :previous_surname, default: false
      t.boolean :marital_status, default: false
      t.boolean :name, default: false
      t.boolean :district, default: false
      t.boolean :dependant, default: false
      t.boolean :product, default: false
      t.boolean :new_dependant, default: false
      t.boolean :view_dependant, default: false
      t.boolean :remove_dependant, default: false
      t.boolean :product_type, default: false
      t.boolean :payment, default: false
      t.boolean :payment_menu, default: false
      t.boolean :airtel, default: false
      t.boolean :tnm, default: false
      t.boolean :claims_menu, default: false
      t.boolean :new_claims_menu, default: false
      t.boolean :view_claims_menu, default: false
      t.boolean :cancel_claims_menu, default: false
      t.timestamps null: false
    end
  end
end
