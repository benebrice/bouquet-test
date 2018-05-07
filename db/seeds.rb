# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Customer.create(email: 'test@bergamotte.com',
                password: 'Bergamotte_2018!!',
                password_confirmation: 'Bergamotte_2018!!',
                first_name: Faker::Name.first_name)

69.times do
  password = Faker::Internet.password
  Customer.create(email: Faker::Internet.email,
                  password: password,
                  password_confirmation: password,
                  first_name: Faker::Name.first_name)
end

5.times do
  Category.create!(name: Faker::Commerce.product_name)
end

15.times do
  Item.create!(name: Faker::Commerce.material)
end

item_ids = Item.pluck(:id)
30.times do
  # Create a product and assign it to a random category (id between 1-5)
  p = Product.create(name: Faker::Book.title, price: Faker::Commerce.price, category_id: rand(1..4))
  item_ids.sample(rand(2..6)).each do |item_id|
    p.product_items.create!(item_id: item_id, quantity: rand(1..10))
  end
end

product_ids = Product.pluck(:id)
statuses = Order.statuses.values
100.times do
  created_datetime = Faker::Time.between(2.months.ago, DateTime.now)
  Order.create!(product_id: product_ids.sample,
                status: statuses.sample,
                created_at: created_datetime,
                updated_at: created_datetime,
                customer_id: rand(1..70))
end
