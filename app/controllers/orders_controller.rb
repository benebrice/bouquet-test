class OrdersController < ApplicationController

  def index
    @orders = current_customer.orders.order(:status)
  end
end
