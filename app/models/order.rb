# app/models/order.rb
# Order made by a customer
class Order < ActiveRecord::Base
  belongs_to :product
  belongs_to :customer
  has_many :items, through: :product

  enum status: %i[daft confirmed canceled]

  scope :weeks_ago, lambda { |from_week, to_week|
    after(from_week).before(to_week)
  }

  scope :before, lambda { |date|
    where('created_at < ?', date.to_i.week.ago)
  }

  scope :after, lambda { |date|
    where('created_at > ?', date.to_i.week.ago)
  }

  scope :confirmed, -> { where(status: 1) }

  scope :from_month, lambda { |month|
    date = Time.zone.now.change(month: month)
    where('created_at > ?', date.beginning_of_month)
      .where('created_at < ?', date.end_of_month)
  }
end
