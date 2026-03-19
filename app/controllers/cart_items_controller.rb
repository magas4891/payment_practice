class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart, only: %i[create update destroy]

  def create
    cart = @cart
    product = Product.find(params[:product_id])
    item = cart.cart_items.find_or_initialize_by(product_id: product.id)
    item.quantity = item.quantity.nil? ? 1 : item.quantity + 1
    item.save!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to products_path }
    end
  end

  def update
    item = @cart.cart_items.find(params[:id])
    item.update!(quantity: params[:quantity])

    respond_to { |f| f.turbo_stream }
  end

  def destroy
    item = @cart.cart_items.find(params[:id])
    item.destroy

    respond_to { |f| f.turbo_stream }
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end
end
