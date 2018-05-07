require 'rails_helper'

describe ProductItem, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to(:item) }
    it { is_expected.to belong_to(:product) }
  end
end
