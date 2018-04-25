class OrdersController < ApplicationController
  before_action :find_orders
  before_action :weeks_filter, only: :analytics

  def index
    h = {my_val_1: {my_val_2: {'my_val_3': 666}}}
    puts h.dig(:my_val_1, :my_val_2, :my_val_3)
  end

  def analytics
    case params[:analysis_type]
    when 'items'
      @items = @orders.includes(:items).map(&:items).uniq.flatten
    else
      @products = @orders.includes(:product).map(&:product).uniq
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def find_orders
    @orders  = current_customer.orders
                               .confirmed
                               .order(created_at: :desc)
  end

  def weeks_filter
    @from_week = params[:from_week].present? ? params[:from_week].to_i : 1
    @to_week = params[:to_week].present? ? params[:to_week].to_i : 0
    @orders = @orders.weeks_ago(@from_week, @to_week)
  end
end
