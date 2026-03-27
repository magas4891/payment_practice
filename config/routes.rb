Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users

  resources :orders
  resources :payments
  resources :products
  resource :cart, only: [ :show ]
  resources :cart_items, only: [ :create, :update, :destroy ]

  post "/checkout",        to: "checkout#create"
  get  "/checkout/success", to: "checkout#success"
  get  "/checkout/cancel",  to: "checkout#cancel"
  post "/webhooks/stripe",  to: "webhooks#stripe"

  post "/subscriptions", to: "subscriptions#create"
  get  "/subscriptions/new", to: "subscriptions#new"
  get  "/subscriptions/success", to: "subscriptions#success"
  get  "/subscriptions/cancel",  to: "subscriptions#cancel"
  get  "/subscriptions/portal", to: "subscriptions#portal"
  get  "/subscriptions/premium", to: "subscriptions#premium"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "products#index"
end
