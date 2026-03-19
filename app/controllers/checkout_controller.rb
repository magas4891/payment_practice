class CheckoutController < ApplicationController
  before_action :authenticate_user!

  def create
    customer = current_user.stripe_customer
    pending_order = current_user.orders.create!(amount: current_user.cart.total_price, currency: "usd", status: "pending")
    order_items = current_user.cart.cart_items.map do |item|
      product = item.product
      pending_order.order_items.create!(product: product, quantity: item.quantity, unit_price: product.price)

      {
        price: item.product.stripe_price_id,
        quantity: item.quantity
      }
    end
    session = Stripe::Checkout::Session.create(
      customer: customer.id,
      mode: "payment",
      line_items: order_items,
      success_url: checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: checkout_cancel_url,
      metadata: { order_id: pending_order.id }
    )
    pending_order.update!(stripe_session_id: session.id)

    redirect_to session.url, allow_other_host: true
  end

  def success
    session_id = params[:session_id]
    session = Stripe::Checkout::Session.retrieve(session_id)

    if session.payment_status == "paid"
      flash[:notice] = "Payment successful!"
      redirect_to root_path
    else
      flash[:alert] = "Payment failed. Please try again."
      redirect_to root_path
    end
  end

  def cancel
    flash[:alert] = "Payment was cancelled. You can try again."
    redirect_to root_path
  end
end
