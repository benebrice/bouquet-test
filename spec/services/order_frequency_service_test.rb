require 'rails_helper'

RSpec.describe OrderService::Frequency do
  
  subject(:frequency_service) { OrderService::Frequency }

  let(:res) { OrderService::Frequency.execute_sql(sql) } 

  let(:customerA) { create(:customer) }
  let(:customerB) { create(:customer) } 
  let(:order1_A) { create(:order, product_id: 1, customer_id: customerA.id) }
  let(:order2_A) { create(:order, product_id: 1, customer_id: customerA.id) }

  let(:order1_B) { create(:order, product_id: 1, customer_id: customerB.id) }
  
  before do
    order1_A
    order2_A
    order1_B
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
    it_behaves_like 'an sql response', shared_sql, ['order_count', 'customer_id']

    it 'returns number of orders per customer' do
      frequencyA = res.select{|hash| hash['customer_id'] == customerA.id}.first
      expect(frequencyA['order_count']).to eq(customerA.orders.count)

      frequencyB = res.select{|hash| hash['customer_id'] == customerB.id}.first
      expect(frequencyB['order_count']).to eq(customerB.orders.count)
    end
  end

  describe 'frequencies_table' do
    let(:res) { frequency_service.frequencies_table }

    # Let `sql` is not avaible outside an `it`.
    shared_sql = OrderService::Frequency.send(:frequencies_table, true)
    it_behaves_like 'an sql query', shared_sql
    it_behaves_like 'an sql response', shared_sql, ['order_count', 'customer_count', 'total_orders']
  end
end