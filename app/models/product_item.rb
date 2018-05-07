# app/models/product_items.rb
# Association model between product and item
class ProductItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :product
end
