class CreateUserDependantSubMenus < ActiveRecord::Migration
  def change
    create_table :user_dependant_sub_menus, :primary_key => :user_dependant_sub_menu_id do |t|
      t.string :user_id
      t.integer :dependant_menu_id
      t.integer :dependant_menu_sub_id
      t.timestamps null: false
    end
  end
end
