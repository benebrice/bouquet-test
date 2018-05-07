require 'rails_helper'

describe Item, type: :model do
  describe 'relations' do
    it { is_expected.to have_many(:product_items) }
    it { is_expected.to have_many(:products) }
  end
end
