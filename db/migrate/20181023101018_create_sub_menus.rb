class CreateSubMenus < ActiveRecord::Migration
  def change
    create_table :sub_menus , :primary_key => :sub_menu_id do |t|
      t.integer :menu_id
      t.string :name
      t.integer :sub_menu_number
      t.timestamps null: false
    end
  end
end
