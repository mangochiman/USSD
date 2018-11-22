class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members, :primary_key => :member_id do |t|
      t.string :user_id
      t.string :phone_number
      t.string :gender
      t.string :title
      t.string :initials
      t.string :first_name
      t.string :surname
      t.string :previous_surname
      t.string :date_of_birth
      t.string :identification_type
      t.string :identification_number
      t.string :country_of_birth
      t.string :nationality
      t.string :marital_status
      t.string :district
      t.string :product
      t.timestamps null: false
    end
  end
end
