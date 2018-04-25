class Order < ActiveRecord::Base
  belongs_to :product

  enum status: [:daft, :confirmed, :canceled]
end
