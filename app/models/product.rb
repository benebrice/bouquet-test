# app/models/product.rb
# Product to buy from the platform
class Product < ActiveRecord::Base
  belongs_to :category
  has_many :orders, dependent: :nullify
  has_many :product_items, dependent: :destroy
  has_many :items, through: :product_items
end
