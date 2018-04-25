class Order < ActiveRecord::Base
  belongs_to :product
  has_many :items, through: :product

  enum status: [:daft, :confirmed, :canceled]

  scope :weeks_ago, -> (from_week = 0, to_week = 1) { 
    where('created_at > ? AND created_at < ?', from_week.to_i.week.ago, to_week.to_i.week.ago)
  }

  scope :confirmed, -> { where( status: 'confirmed')}

end
