class AddStripeSessionIdToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :stripe_session_id, :string
  end
end
