module SubscriptionsHelper
  def subscribed?
    status = current_user&.subscription_status
    status.eql?("active") || status.eql?("trialing")
  end

  def subscription_active?
    return false unless subscribed?

    current_user&.current_period_end&.future?
  end
end
