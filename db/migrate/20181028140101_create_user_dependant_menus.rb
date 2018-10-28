class CreateUserDependantMenus < ActiveRecord::Migration
  def change
    create_table :user_dependant_menus, :primary_key => :user_dependant_menu_id do |t|
      t.string :user_id
      t.integer :dependant_menu_id
      t.timestamps null: false
    end
  end
end
