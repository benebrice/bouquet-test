class OrdersController < ApplicationController
  before_action :find_orders, :week_paramters
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

  def frequencies
    # global_order_count_sql = "SELECT count(id) AS 'all_orders'
    #                           FROM orders 
    #                           WHERE created_at > '#{@from_week.week.ago.utc.to_s(:db)}'
    #                           AND created_at < '#{@to_week.week.ago.utc.to_s(:db)}'"
    global_order_count_sql = "SELECT count(id) AS 'all_orders'
                              FROM orders"
    freq_order_count = "SELECT count(*) AS 'order_count', customer_id
                        FROM orders o
                        GROUP BY customer_id
                        ORDER BY 'order_count'"
    sql = "SELECT order_count, count(*) AS 'customer_count', (#{global_order_count_sql}) AS 'total_orders'
          FROM
            (#{freq_order_count})
          GROUP BY order_count
          ORDER BY order_count"
    ap sql
    @frequencies = ActiveRecord::Base.connection.execute(sql)
  end

  private

  def find_orders
    @orders  = current_customer.orders.confirmed.order(created_at: :desc)
  end

  def week_paramters
    @from_week = params[:from_week].present? ? params[:from_week].to_i : 1
    @to_week = params[:to_week].present? ? params[:to_week].to_i : 0    
  end

  def weeks_filter
    @orders = @orders.weeks_ago(@from_week, @to_week)
  end
end
