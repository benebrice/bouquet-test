require 'rails_helper'

describe Customer, type: :model do
  describe 'relations' do
    it { is_expected.to have_many(:orders) }
    it { is_expected.to have_many(:products) }
  end
end
