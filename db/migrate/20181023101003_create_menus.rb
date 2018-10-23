class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus, :primary_key => :menu_id do |t|
      t.integer :menu_number
      t.string :name
      t.timestamps null: false
    end
  end
end
