class CreateSeenStatuses < ActiveRecord::Migration
  def change
    create_table :seen_statuses, :primary_key => :seen_status_id do |t|
      t.string :user_id
      t.boolean :phone_number, default: false
      t.boolean :gender, default: false
      t.boolean :name, default: false
      t.boolean :district, default: false
      t.boolean :dependant, default: false
      t.boolean :new_dependant, default: false
      t.boolean :view_dependant, default: false
      t.boolean :remove_dependant, default: false
      t.boolean :product_type, default: false
      t.boolean :payment, default: false
      t.boolean :payment_menu, default: false
      t.boolean :airtel, default: false
      t.boolean :tnm, default: false
      t.boolean :claims_menu, default: false
      t.timestamps null: false
    end
  end
end
