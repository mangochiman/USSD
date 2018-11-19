class CreateMaritalStatuses < ActiveRecord::Migration
  def change
    create_table :marital_statuses, :primary_key => :marital_status_id do |t|
      t.integer :menu_number
      t.string :name
      t.timestamps null: false
    end
  end
end
