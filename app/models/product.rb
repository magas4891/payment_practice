class Product < ApplicationRecord
  has_many :order_items
  has_many :orders, through: :order_items

  validates :title, presence: true
  validates :description, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  def self.ransackable_associations(auth_object = nil)
    %w[order_items orders]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at description id id_value price stripe_price_id stripe_product_id title updated_at]
  end
end
