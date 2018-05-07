require 'rails_helper'

RSpec.describe OrderService do
  subject(:service_class) { OrderService }
  subject(:service) { service_class.new }

  let(:customer_a) { create(:customer) }
  let(:customer_a) { create(:customer) }

  let(:product1) { create(:product) }
  let(:product2) { create(:product) }

  let(:item1) { create(:item) }
  let(:item2) { create(:item) }

  let(:product_item1) { create(:product_item, product_id: product1.id, item_id: item1.id) }
  let(:product_item2) { create(:product_item, product_id: product2.id, item_id: item2.id) }

  let(:order1_a) do
    create(:order,
           product_id: product1.id,
           customer_id: customer_a.id)
  end
  let(:order2_a) do
    create(:order,
           product_id: product2.id,
           customer_id: customer_a.id)
  end
  let(:order1_b) do
    create(:order,
           product_id: product1.id,
           customer_id: customer_a.id)
  end

  context 'Initialize' do
    describe 'class methods' do
      it 'returns integer' do
        expect(service_class.send(:integer_with_default_value, '1', 2)).to eq(1)
      end

      it 'returns integer default value' do
        expect(service_class.send(:integer_with_default_value, nil, 2)).to eq(2)
      end
    end

    describe 'instance methods' do
      it 'creates an empty ActiveRecord::Relation for orders' do
        expect(service.orders).to be_a(ActiveRecord::Relation)
      end

      it 'sanitizes options with default values' do
        expect(service.options).to be_a(Hash)
        expect(service.options[:from_week]).to eq(1)
        expect(service.options[:to_week]).to eq(0)
        expect(service.options[:analysis_type]).to eq('all')
      end

      it 'sanitizes options with items type' do
        serv = service_class.new(nil, analysis_type: 'items')
        expect(serv.options[:analysis_type]).to eq('items')
      end

      it 'sanitizes options with products type' do
        serv = service_class.new(nil, analysis_type: 'products')
        expect(serv.options[:analysis_type]).to eq('products')
      end

      it 'has filters' do
        expect(service.no_filter?).to be false
      end
    end
  end

  context 'Instanciate service' do
    describe 'filters on orders' do
      before do
        order1_a
        order1_b
        order2_a
        service.load_orders
      end

      it 'load orders' do
        expect(service.orders.count).not_to eq(0)
      end

      it 'applies filters' do
        expect(service.apply_filter.to_sql).to include('created_at >')
        expect(service.apply_filter.to_sql).to include('created_at <')
      end

      it 'load_items' do
        product_item1
        product_item2
        service.load_items
        expect(service.items.map(&:id)).to contain_exactly(product_item1.id, product_item2.id)
      end

      it 'load_products' do
        service.load_products
        expect(service.products.map(&:id)).to contain_exactly(product1.id, product2.id)
      end
    end
  end
end
