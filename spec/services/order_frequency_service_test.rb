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

    it 'returns a String containing SELECT and FROM' do
      expect(sql).to be_a(String)
      expect(sql).to include('SELECT', 'FROM')
    end

    it 'returns an Array of Hash (min 1 element)' do
      expect(res).to be_a(Array)
      expect(res.count).to be > 0
      expect(res.first).to be_a(Hash)
    end

    it 'returns a Hash with key `all_orders`' do
      expect(res.first.has_key?('all_orders')).to be_truthy
    end

    it 'returns the number of all orders' do
      expect(res.first['all_orders']).to eq(Order.count)
    end
  end

  describe 'total_orders_by_customer_table' do
    let(:sql) { frequency_service.send(:total_orders_by_customer_table) }

    it 'returns a String containing SELECT and FROM' do
      expect(sql).to be_a(String)
      expect(sql).to include('SELECT', 'FROM')
    end

    it 'returns an Array of Hash (min 1 element)' do
      expect(res).to be_a(Array)
      expect(res.count).to be > 0
      expect(res.first).to be_a(Hash)
    end

    it 'returns a hashes with both keys `order_count` and `customer_id`' do
      res.each do |r|
        expect(r.has_key?('order_count')).to be_truthy
        expect(r.has_key?('customer_id')).to be_truthy
      end
    end

    it 'returns number of orders per customer' do
      frequencyA = res.select{|hash| hash['customer_id'] == customerA.id}.first
      expect(frequencyA['order_count']).to eq(customerA.orders.count)

      frequencyB = res.select{|hash| hash['customer_id'] == customerB.id}.first
      expect(frequencyB['order_count']).to eq(customerB.orders.count)
    end
  end

  describe 'frequencies_table' do
    let(:res) { frequency_service.frequencies_table }

    it 'returns an Array of Hash (min 1 element)' do
      expect(res).to be_a(Array)
      expect(res.count).to be > 0
      expect(res.first).to be_a(Hash)
    end

    it 'returns a hashes with both keys `order_count` and `customer_id`' do
      res.each do |r|
        expect(r.has_key?('order_count')).to be_truthy
        expect(r.has_key?('customer_count')).to be_truthy
        expect(r.has_key?('total_orders')).to be_truthy
      end
    end
  end
end