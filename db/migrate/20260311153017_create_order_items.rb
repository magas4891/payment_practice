class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order
      t.references :product
      t.integer    :quantity
      t.integer    :unit_price
      t.timestamps
    end
  end
end
