class Order < ActiveRecord::Base
  belongs_to :product
  belongs_to :customer
  has_many :items, through: :product

  enum status: [:daft, :confirmed, :canceled]

  scope :weeks_ago, -> (from_week = 0, to_week = 1) { 
    after(from_week).before(to_week)
  }

  scope :before, -> (date) {
    where('created_at < ?', date.to_i.week.ago)
  }

  scope :after, -> (date) {
    where('created_at > ?', date.to_i.week.ago)
  }
  scope :confirmed, -> { where( status: 'confirmed')}

end
