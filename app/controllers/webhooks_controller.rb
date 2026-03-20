class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      render json: { error: "Invalid payload" }, status: 400 and return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: "Invalid signature" }, status: 400 and return
    end

    case event.type
    when "checkout.session.completed"
      session = event.data.object

      return render json: { received: true } unless session["payment_status"] == "paid"

      user = User.find_by(stripe_customer_id: session["customer"])
      user.update(paid: true) if user

      order = user.orders.find_by(stripe_session_id: session["id"])
      order.update!(status: "paid")

      user.cart.destroy!
    when "checkout.session.expired"
      # user abandoned checkout, clean up pending order if you created one
    when "charge.dispute.created"
      # someone filed a chargeback — flag the order
    end

    render json: { received: true }
  end
end
