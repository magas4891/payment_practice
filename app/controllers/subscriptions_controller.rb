class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @plans = available_plans
    @current_plan_id = current_user&.plan
  end

  def create
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Please sign in to subscribe."
      return
    end

    plan = Product.find(params[:price_id]).presence
    unless plan
      redirect_to subscriptions_new_url, alert: "Missing subscription plan."
      return
    end
    price_id = plan.stripe_price_id
    customer = current_user.stripe_customer
    session = Stripe::Checkout::Session.create(
      customer: customer.id,
      mode: "subscription",
      line_items: [{ price: price_id, quantity: 1 }],
      success_url: subscriptions_success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: subscriptions_cancel_url
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
    session_id = params[:session_id]
    flash.now[:notice] = "Stripe checkout completed. Premium access may take a moment to activate."
    @session = session_id.present? ? Stripe::Checkout::Session.retrieve(session_id) : nil
  end

  def cancel
    subscription_id = current_user.stripe_subscription_id
    Stripe::Subscription.cancel(subscription_id)
    flash.now[:alert] = "Subscription checkout was cancelled."
  end

  def portal
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Please sign in to manage your subscription."
      return
    end

    session = Stripe::BillingPortal::Session.create(
      customer: current_user.stripe_customer_id,
      return_url: subscriptions_premium_url
    )
    redirect_to session.url, allow_other_host: true
  end

  def premium
    @plans = available_plans
    @current_plan_id = current_user&.plan
    @current_plan = @plans.find { |p| p[:price_id] == @current_plan_id } if @current_plan_id
  end

  private

  def available_plans
    Product.where(id: [51, 52])
  end
end
