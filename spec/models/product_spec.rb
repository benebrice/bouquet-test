require 'rails_helper'

describe Product, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to(:category) }
    it { is_expected.to have_many(:orders) }
    it { is_expected.to have_many(:product_items) }
    it { is_expected.to have_many(:items) }
  end
end
