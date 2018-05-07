class Order < ActiveRecord::Base
  belongs_to :product
  belongs_to :customer
  has_many :items, through: :product

  enum status: %i[daft confirmed canceled]

  scope :weeks_ago, ->(from_week = 0, to_week = 1) {
    after(from_week).before(to_week)
  }

  scope :before, ->(date) {
    where('created_at < ?', date.to_i.week.ago)
  }

  scope :after, ->(date) {
    where('created_at > ?', date.to_i.week.ago)
  }

  scope :confirmed, -> { where(status: 1) }

  scope :from_month, ->(month) {
    date = Time.zone.now.change(month: month)
    where('created_at > ?', date.beginning_of_month)
      .where('created_at < ?', date.end_of_month)
  }
end
