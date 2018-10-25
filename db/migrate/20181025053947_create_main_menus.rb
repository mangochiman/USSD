class CreateMainMenus < ActiveRecord::Migration
  def change
    create_table :main_menus, :primary_key => :main_menu_id do |t|
      t.integer :menu_number
      t.string :name
      t.timestamps null: false
    end
  end
end
