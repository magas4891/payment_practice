class AddColumnsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :stripe_customer_id, :string
    add_column :users, :paid, :boolean
  end
end
