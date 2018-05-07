FactoryBot.define do
  factory :product_item, class: 'ProductItem' do |f|
    f.sequence(:quantity) { rand(1..10) }
  end
end
