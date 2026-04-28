class User < ApplicationRecord
  after_create :ensure_cart

  has_one :cart
  has_many :orders

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def stripe_customer
    return Stripe::Customer.retrieve(stripe_customer_id) if stripe_customer_id.present?

    created_customer = Stripe::Customer.create(
      email: email,
      name: "#{first_name} #{last_name}",
      metadata: { user_id: id }
    )
    update!(stripe_customer_id: created_customer.id)

    created_customer
  end

  def active_subscriber?
    subscription_status == 'active'
  end

  def active_subscription?
    current_period_end.present? && current_period_end > Time.current.beginning_of_day
  end

  private

  def ensure_cart
    Cart.create(user: self)
  end
end
