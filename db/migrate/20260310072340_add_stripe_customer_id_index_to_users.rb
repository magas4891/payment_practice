class AddStripeCustomerIdIndexToUsers < ActiveRecord::Migration[8.1]
  def change
    add_index :users, :stripe_customer_id, unique: true
  end
end
