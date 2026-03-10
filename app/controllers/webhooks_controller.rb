class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def stripe
    pp ' *** '*100, request.env
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
      product_id     = session['metadata']['product_id']
      # Mark the user as having paid and associate the product
      user = User.find_by(stripe_customer_id: session.customer)
      if user
        user.update(paid: true)
        # Optionally, you can create a record of the purchase here
      end
      Order.create!(
        product_id:        product_id,
        stripe_session_id: session['id'],
        status:            'paid'
      )
    end

    render json: { received: true }
  end
end
