class AddStripePriceIdToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :stripe_product_id, :string
    add_column :products, :stripe_price_id, :string
  end
end
