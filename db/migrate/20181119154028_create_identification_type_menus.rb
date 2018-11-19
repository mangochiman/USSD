class CreateIdentificationTypeMenus < ActiveRecord::Migration
  def change
    create_table :identification_type_menus, :primary_key => :identification_type_menu_id do |t|
      t.integer :menu_number
      t.string :name
      t.timestamps null: false
    end
  end
end
