class CreateUserClaimsSubMenus < ActiveRecord::Migration
  def change
    create_table :user_claims_sub_menus, :primary_key => :user_claim_sub_menu_id do |t|
      t.string :user_id
      t.integer :claim_menu_id
      t.integer :claim_menu_sub_id
      t.timestamps null: false
    end
  end
end
