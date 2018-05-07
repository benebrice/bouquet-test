# app/controllers/orders_controller.rb
# Controller of orders
class OrdersController < ApplicationController
  def index
    h = { my_val_1: { my_val_2: { 'my_val_3': 666 } } }
    puts h.dig(:my_val_1, :my_val_2, :my_val_3)
  end

  def analytics
    service = OrderService.new(nil, generate_options)
    # service = OrderService.new(current_customer, generate_options)
    @orders = service.load_orders
    service.send("load_#{service.options[:analysis_type]}")

    load_variables(service)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def frequencies
    @frequencies = OrderService::Frequency.frequencies_table
  end

  def recurrences
    @recurrences = OrderService::Recurrence.recurrences_table
  end

  private

  def generate_options
    {
      analysis_type: params[:analysis_type],
      from_week: params[:from_week],
      to_week: params[:to_week]
    }
  end

  def load_variables(service)
    @items = service.items
    @products = service.products
    @older_orders_counter = service.order_before
    @from_week = service.options[:from_week]
    @to_week = service.options[:to_week]
  end
end
