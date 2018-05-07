# app/models/item.rb
# Item of a product
class Item < ActiveRecord::Base
  has_many :product_items, dependent: :destroy
  has_many :products, through: :product_items
end
