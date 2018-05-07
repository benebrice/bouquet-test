require 'rails_helper'

RSpec.describe OrderService do
  
  context 'Initialize' do
    subject(:service) { OrderService.new(nil)}

    it 'sanitizes options' do
      expect(service.options).to be_a(Hash)
    end

    it 'creates an empty ActiveRecord::Relation for orders' do
      expect(service.orders).to be_a(ActiveRecord::Relation)
    end
  end
end