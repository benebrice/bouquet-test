FactoryBot.define do
  factory :product, class: 'Product' do |f|
    name  Faker::Book.title
    price Faker::Commerce.price
  end
end
