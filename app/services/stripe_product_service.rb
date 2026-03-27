class StripeProductService
  def initialize(product)
    @product = product
  end

  def call
    stripe_product = ensure_stripe_product!
    ensure_stripe_price!(stripe_product) if stripe_product
  end

  private

  attr_reader :product

  def ensure_stripe_product!
    return Stripe::Product.retrieve(product.stripe_product_id) if product.stripe_product_id.present?

    stripe_product = Stripe::Product.create(
      name: product.title,
      description: product.description,
    )
    product.update!(stripe_product_id: stripe_product.id)
    stripe_product
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe error: #{e.message}")
    raise
  end

  def ensure_stripe_price!(stripe_product)
    return Stripe::Price.retrieve(product.stripe_price_id) if product.stripe_price_id.present?

    stripe_price = Stripe::Price.create(
      product: stripe_product.id,
      unit_amount: unit_amount_cents,
      currency: 'usd',
    )
    product.update!(stripe_price_id: stripe_price.id)
    stripe_price
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe error: #{e.message}")
    raise
  end

  def unit_amount_cents
    (BigDecimal(product.price.to_s) * 100).to_i
  end
end
