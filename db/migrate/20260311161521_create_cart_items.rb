class CreateCartItems < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_items do |t|
      t.references :cart
      t.references :product
      t.integer    :quantity
      t.timestamps
    end
  end
end
