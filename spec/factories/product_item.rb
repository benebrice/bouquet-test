FactoryBot.define do
  factory :product_item, class: 'ProductItem' do |f|
    f.sequence(:quantity) { rand(10) + 1 }
  end
end
