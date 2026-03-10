class CheckoutController < ApplicationController
  before_action :authenticate_user!

  def create
    product = Product.find(params[:product_id])
    customer = current_user.stripe_customer

    session = Stripe::Checkout::Session.create(
      customer: customer.id,
      mode: 'payment',
      line_items: [{
                     price: product.stripe_price_id,
                     quantity: 1
                   }],
      success_url: checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: checkout_cancel_url,
      metadata: { product_id: product.id }
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
    session_id = params[:session_id]
    session = Stripe::Checkout::Session.retrieve(session_id)

    if session.payment_status == 'paid'
      product_id = session.metadata.product_id
      product = Product.find(product_id)

      # Mark the user as having paid and associate the product
      current_user.update(paid: true)

      # Optionally, you can create a record of the purchase here

      flash[:notice] = "Payment successful! You have access to #{product.title}."
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
