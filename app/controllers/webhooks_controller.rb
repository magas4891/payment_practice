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
      if order
        order.update!(status: "paid")
        user.cart.destroy!
      end
    when "checkout.session.expired"
      # user abandoned checkout, clean up pending order if you created one
    when "charge.dispute.created"
      # someone filed a chargeback — flag the order
    when 'customer.subscription.created'
      sub  = event['data']['object']
      user = User.find_by(stripe_customer_id: sub['customer'])
      user&.update!(
        stripe_subscription_id: sub['id'],
        subscription_status:    sub['status'],
        current_period_end:     Time.at(sub['current_period_end']),
        plan:                   sub['items']['data'][0]['price']['id']
      )
    when 'customer.subscription.updated'
      sub  = event['data']['object']
      user = User.find_by(stripe_customer_id: sub['customer'])
      user&.update!(
        subscription_status: sub['status'],
        current_period_end:  Time.at(sub['current_period_end']),
        plan:                sub['items']['data'][0]['price']['id']
      )
    when 'customer.subscription.deleted'
      sub  = event['data']['object']
      user = User.find_by(stripe_customer_id: sub['customer'])
      user&.update!(
        subscription_status:    'canceled',
        stripe_subscription_id: nil
      )
      # send 'sorry to see you go' email
    when 'invoice.payment_failed'
      invoice = event['data']['object']
      user = User.find_by(stripe_customer_id: invoice['customer'])
      # UserMailer.payment_failed(user).deliver_later
    end

    render json: { received: true }
  end
end
