FactoryBot.define do
  factory :customer, class: 'Customer' do |f|
    password  Faker::Internet.password
    f.sequence(:email) { |n| "customer_#{n}@theawesomecompany.com" }
    f.sequence(:first_name) { Faker::Name.first_name }
  end
end
