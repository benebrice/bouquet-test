require 'rails_helper'
#require 'factories/customer_spec' 

describe OrdersController, type: :controller do
  describe "GET analytics" do
    let(:customer) { create(:customer) }

    let(:product) { create(:product) }

    let(:order1) do
    create(:order,
           product_id: product.id,
           customer_id: customer.id)
    end
    let(:order2) do
      create(:order,
             product_id: product.id,
             customer_id: customer.id)
    end

    before do
      order1
      order2
    end
  
    it "assigns @orders" do
      sign_in customer
      get :analytics
      expect(assigns(:orders)).to be_a(ActiveRecord::Relation)
    end

    it "assigns @older_orders_counter" do
      sign_in customer
      get :analytics
      expect(assigns(:older_orders_counter)).to be_a(Fixnum)
    end

    it "assigns @from_week and @to_week" do
      sign_in customer
      get :analytics
      expect(assigns(:from_week)).to be_a(Fixnum)
      expect(assigns(:to_week)).to be_a(Fixnum)
    end
  end
end