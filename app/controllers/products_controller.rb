class ProductsController < ApplicationController
  def index
    @products = Product.all.order(created_at: :asc)
  end
end
