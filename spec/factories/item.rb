FactoryBot.define do
  factory :item, class: 'Item' do |_f|
    name Faker::Commerce.material
  end
end
