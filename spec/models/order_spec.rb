require 'rails_helper'

describe Order, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to(:product) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to have_many(:items) }
  end
end
