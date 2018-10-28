class CreateDependantMenus < ActiveRecord::Migration
  def change
    create_table :dependant_menus, :primary_key => :dependant_menu_id do |t|
      t.integer :menu_number
      t.string :name
      t.timestamps null: false
    end
  end
end
