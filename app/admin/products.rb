ActiveAdmin.register Product do
  permit_params :title, :description, :price

  controller do
    def create
      super do |success, failure|
        success.html do
          begin
            StripeProductService.new(resource).call
            redirect_to admin_product_path(resource), notice: 'Product successfully created!'
          rescue Stripe::StripeError => e
            redirect_to admin_product_path(resource), alert: "Product saved, but Stripe sync failed: #{e.message}"
          end
        end
        failure.html { render :new }
      end
    end
  end
end
