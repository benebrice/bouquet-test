require 'rails_helper'

describe OrdersController, type: :controller do
  let(:customer) { create(:customer) }

  describe 'GET analytics' do
    subject { get :index }

    it 'cannot access without login' do
      expect(subject).to redirect_to(new_customer_session_path)
    end

    it 'render index view' do
      sign_in customer
      expect(subject).to render_template(:index)
    end
  end

  describe 'GET analytics' do
    subject { get :analytics }

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

    describe 'view rendering' do
      it 'cannot access without login' do
        expect(subject).to redirect_to(new_customer_session_path)
      end

      it 'render index view' do
        sign_in customer
        expect(subject).to render_template('orders/analytics')
      end
    end

    describe 'variable assignments' do
      it 'assigns @orders' do
        sign_in customer
        subject
        expect(assigns(:orders)).to be_a(ActiveRecord::Relation)
      end

      it 'assigns @older_orders_counter' do
        sign_in customer
        subject
        expect(assigns(:older_orders_counter)).to be_a(Integer)
      end

      it 'assigns @from_week and @to_week' do
        sign_in customer
        subject
        expect(assigns(:from_week)).to be_a(Integer)
        expect(assigns(:to_week)).to be_a(Integer)
      end
    end
  end

  describe 'GET frequencies' do
    subject { get :frequencies }

    it 'cannot access without login' do
      expect(subject).to redirect_to(new_customer_session_path)
    end

    it 'render index view' do
      sign_in customer
      expect(subject).to render_template(:frequencies)
    end
  end

  describe 'GET recurrences' do
    subject { get :recurrences }

    it 'cannot access without login' do
      expect(subject).to redirect_to(new_customer_session_path)
    end

    it 'render index view' do
      sign_in customer
      expect(subject).to render_template(:recurrences)
    end
  end
end
