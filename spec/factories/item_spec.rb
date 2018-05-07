FactoryBot.define do
  factory :item, class: 'Item' do |f|
    name Faker::Commerce.material
  end 
end
