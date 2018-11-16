class CreateUserClaimMenus < ActiveRecord::Migration
  def change
    create_table :user_claim_menus, :primary_key => :user_claim_menu_id do |t|
      t.string :user_id
      t.integer :claim_menu_id
      t.timestamps null: false
    end
  end
end
