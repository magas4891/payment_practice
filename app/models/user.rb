class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
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
end
