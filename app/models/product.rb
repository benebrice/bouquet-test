class Product < ActiveRecord::Base
  belongs_to :category
  has_many :orders
  has_many :product_items
  has_many :items, through: :product_items
end
