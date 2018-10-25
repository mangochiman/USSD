class CreateMainSubMenus < ActiveRecord::Migration
  def change
    create_table :main_sub_menus, :primary_key => :main_sub_menu_id do |t|
      t.integer :main_menu_id
      t.string :name
      t.integer :sub_menu_number
      t.timestamps null: false
    end
  end
end
