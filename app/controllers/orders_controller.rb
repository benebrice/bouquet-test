class OrdersController < ApplicationController

  def index
    @orders = current_customer.orders.order(:status)
    h = {my_val_1: {my_val_2: {'my_val_3': 666}}}
    puts h.dig(:my_val_1, :my_val_2, :my_val_3)
  end

  def analytics
    
  end
end
