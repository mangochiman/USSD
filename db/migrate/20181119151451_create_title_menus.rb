class CreateTitleMenus < ActiveRecord::Migration
  def change
    create_table :title_menus, :primary_key => :title_menu_id do |t|
      t.integer :menu_number
      t.string :name
      t.timestamps null: false
    end
  end
end
