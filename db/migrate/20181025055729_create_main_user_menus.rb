class CreateMainUserMenus < ActiveRecord::Migration
  def change
    create_table :main_user_menus, :primary_key => :main_user_menu_id do |t|
      t.string :user_id
      t.integer :main_menu_id
      t.integer :main_sub_menu_id
      t.timestamps null: false
    end
  end
end
