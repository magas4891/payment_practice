class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def total_price
    cart_items.includes(:product).sum do |cart_item|
      cart_item.quantity * cart_item.product.price
    end
  end
end
