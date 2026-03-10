class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.decimal :amount
      t.string :currency
      t.string :status
      t.integer :user_id

      t.timestamps
    end
  end
end
