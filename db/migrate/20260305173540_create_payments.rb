class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.string :stripe_charge_id
      t.integer :amount
      t.string :currency
      t.string :status
      t.integer :order_id

      t.timestamps
    end
  end
end
