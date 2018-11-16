class CreateClaims < ActiveRecord::Migration
  def change
    create_table :claims, :primary_key => :claim_id do |t|
      t.string :member_id
      t.string :description
      t.boolean :voided, default: false
      t.timestamps null: false
    end
  end
end
