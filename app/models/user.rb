class User < ApplicationRecord
  after_create :ensure_cart

  has_one :cart
  has_many :orders

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def stripe_customer
    if stripe_customer_id.present?
      Stripe::Customer.retrieve(stripe_customer_id)
    else
      customer = Stripe::Customer.create(
        email: email,
        name: "#{first_name} #{last_name}",
        metadata: { user_id: id }
      )
      update!(stripe_customer_id: customer.id)

      customer
    end
  end

  private

  def ensure_cart
    Cart.create(user: self)
  end
end
