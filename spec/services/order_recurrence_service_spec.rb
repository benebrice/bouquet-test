require 'rails_helper'

RSpec.describe OrderService::Recurrence do
  subject(:recurrence_service) { OrderService::Recurrence }

  let(:res) { OrderService::Recurrence.execute_sql(sql) }

  let(:customer_a) { create(:customer) }
  let(:customer_b) { create(:customer) }
  let(:order1_a) { create(:order, product_id: 1, customer_id: customer_a.id) }
  let(:order2_a) { create(:order, product_id: 1, customer_id: customer_a.id) }

  let(:order1_b) { create(:order, product_id: 1, customer_id: customer_b.id) }

  before do
    order1_a
    order2_a
    order1_b
  end

  describe 'customer_first_order_table' do
    let(:sql) { recurrence_service.send(:customer_first_order_table) }

    # Let `sql` is not avaible outside an `it`.
    shared_sql = OrderService::Recurrence.send(:customer_first_order_table)
    it_behaves_like 'an sql query', shared_sql
    it_behaves_like 'an sql response', shared_sql, %w[customer_id first_order_on_month]

    it 'returns the date of the first order of every customer' do
      res.each do |r|
        order = Customer.find(r['customer_id']).orders.order(:created_at).first
        expect(DateTime.parse(r['first_order_on_month'])).to eq(order.created_at)
      end
    end
  end

  describe 'orders_by_customer_by_month_table' do
    let(:sql) { recurrence_service.send(:orders_by_customer_by_month_table) }

    # Let `sql` is not avaible outside an `it`.
    shared_sql = OrderService::Recurrence.send(:orders_by_customer_by_month_table)
    it_behaves_like 'an sql query', shared_sql
    it_behaves_like 'an sql response', shared_sql, %w[order_month customer_id total_customer_order]

    it 'returns number of orders per customer per month' do
      res.each do |r|
        orders = Customer.find(r['customer_id']).orders.from_month(r['order_month'])
        expect(r['total_customer_order']).to eq(orders.count)
      end
    end
  end

  describe 'customer_orders_by_months_table' do
    let(:sql) { recurrence_service.send(:customer_orders_by_months_table) }

    # Let `sql` is not avaible outside an `it`.
    shared_sql = OrderService::Recurrence.send(:customer_orders_by_months_table)
    it_behaves_like 'an sql query', shared_sql
    it_behaves_like 'an sql response', shared_sql, %w[order_month customer_id total_orders first_order_on_month]

    it_behaves_like 'a sub query', shared_sql, OrderService::Recurrence.send(:orders_by_customer_by_month_table)
    it_behaves_like 'a sub query', shared_sql, OrderService::Recurrence.send(:customer_first_order_table)

    it 'returns number of orders per customer per month' do
      res.each do |r|
        orders = Customer.find(r['customer_id']).orders.from_month(r['order_month'])
        expect(r['total_orders']).to eq(orders.count)
      end
    end
  end

  describe 'recurrences' do
    # Let `sql` is not avaible outside an `it`.
    shared_sql = OrderService::Recurrence.send(:recurrences)
    it_behaves_like 'an sql query', shared_sql
    it_behaves_like 'an sql response', shared_sql, %w[order_month recurrence_customers orders_on_month]
  end
end
