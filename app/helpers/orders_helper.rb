# app/helpers/orders_helpers
# Helper for orders
module OrdersHelper
  def month_displayer(number)
    number.to_i.weeks.ago.strftime('%Y/%m/%d')
  end
end
