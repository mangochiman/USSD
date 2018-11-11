class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members, :primary_key => :member_id do |t|
      t.string :phone_number
      t.string :gender
      t.string :name
      t.string :district
      t.string :product
      t.timestamps null: false
    end
  end
end
