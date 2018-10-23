class CreateUserMenus < ActiveRecord::Migration
  def change
    create_table :user_menus, :primary_key => :user_menu_id do |t|
      t.string :user_id
      t.integer :menu_id
      t.integer :sub_menu_id
      t.timestamps null: false
    end
  end
end
