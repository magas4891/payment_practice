class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    Rails.logger.info "===***=== WEBHOOK HIT ===***==="
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      render json: { error: "Invalid payload" }, status: 400 and return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: "Invalid signature" }, status: 400 and return
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      user = User.find_by(stripe_customer_id: session['customer'])
      user.update(paid: true) if user

      Order.create!(
        user:              user,
        status:            'paid'
      )
    end

    render json: { received: true }
  end
end
