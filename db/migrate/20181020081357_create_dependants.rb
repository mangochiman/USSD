class CreateDependants < ActiveRecord::Migration
  def change
    create_table :dependants, :primary_key => :dependant_id do |t|
      t.integer :member_id
      t.string :phone_number
      t.string :gender
      t.string :name
      t.string :district
      t.timestamps null: false
    end
  end
end
