class CreateUserParentMenus < ActiveRecord::Migration
  def change
    create_table :user_parent_menus, :primary_key => :user_parent_menu_id do |t|
      t.string :user_id
      t.timestamps null: false
    end
  end
end
