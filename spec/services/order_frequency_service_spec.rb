require 'rails_helper'

RSpec.describe OrderService::Frequency do
  subject(:frequency_service) { OrderService::Frequency }

  let(:res) { OrderService::Frequency.execute_sql(sql) }

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

  describe 'total_orders' do
    let(:sql) { frequency_service.send(:total_orders) }

    # Let `sql` is not avaible outside an `it`.
    shared_sql = OrderService::Frequency.send(:total_orders)
    it_behaves_like 'an sql query', shared_sql
    it_behaves_like 'an sql response', shared_sql, ['all_orders']

    it 'returns the number of all orders' do
      expect(res.first['all_orders']).to eq(Order.count)
    end
  end

  describe 'total_orders_by_customer_table' do
    let(:sql) { frequency_service.send(:total_orders_by_customer_table) }

    # Let `sql` is not avaible outside an `it`.
    shared_sql = OrderService::Frequency.send(:total_orders_by_customer_table)
    it_behaves_like 'an sql query', shared_sql
    it_behaves_like 'an sql response', shared_sql, %w[order_count customer_id]

    it 'returns number of orders per customer' do
      frequency_a = res.select { |hash| hash['customer_id'] == customer_a.id }.first
      expect(frequency_a['order_count']).to eq(customer_a.orders.count)

      frequency_b = res.select { |hash| hash['customer_id'] == customer_b.id }.first
      expect(frequency_b['order_count']).to eq(customer_b.orders.count)
    end
  end

  describe 'frequencies' do
    # Let `sql` is not avaible outside an `it`.
    shared_sql = OrderService::Frequency.send(:frequencies)
    it_behaves_like 'an sql query', shared_sql
    it_behaves_like 'an sql response', shared_sql, %w[order_count customer_count total_orders]
  end
end
