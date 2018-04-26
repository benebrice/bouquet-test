class OrdersController < ApplicationController
  before_action :find_orders, :week_paramters
  before_action :count_older_orders, :weeks_filter, only: :analytics

  def index
    h = {my_val_1: {my_val_2: {'my_val_3': 666}}}
    puts h.dig(:my_val_1, :my_val_2, :my_val_3)
  end

  def analytics
    case params[:analysis_type]
    when 'items'
      @items = @orders.includes(:items).map(&:items).uniq.flatten
    when 'products'
      @products = @orders.includes(:product).map(&:product).uniq
    else
      @items = @orders.includes(:items).map(&:items).uniq.flatten
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
    @frequencies = ActiveRecord::Base.connection.execute(sql)
  end

  def recurrence
    global_order_count_sql = "SELECT count(id) AS 'all_orders'
                              FROM orders"

    month_customer_first_order_sql = "SELECT strftime('%m', datetime(created_at)) as order_month, customer_id, min(created_at) AS 'first_order_on_month', max(created_at) AS 'last_order_on_month'
                                      FROM orders
                                      GROUP BY customer_id"
    customer_first_order_sql = "SELECT customer_id, min(created_at) AS 'first_order_on_month'
                                FROM orders
                                group by customer_id"
    orders_by_customer_by_month = "SELECT CAST(strftime('%m', datetime(created_at)) as int) as order_month, customer_id, count(*) as total_customer_order
                                  FROM orders o1  
                                  GROUP BY customer_id, order_month"
    sql = "SELECT order_month, count(*) as 'recurrence_customers', sum(total_orders) as 'orders_on_month'
            FROM
              (SELECT order_month, A.customer_id, sum(total_customer_order) AS 'total_orders', first_order_on_month
                FROM 
                  (#{orders_by_customer_by_month}) A
                LEFT JOIN
                  (#{customer_first_order_sql}) B
                ON A.customer_id = B.customer_id
                GROUP BY order_month, A.customer_id)
            GROUP BY order_month
            HAVING COUNT(CAST(strftime('%m', datetime(first_order_on_month)) as int) < order_month)"

    @recurrences = ActiveRecord::Base.connection.execute(sql)
  end

  private

  def find_orders
    # @orders  = current_customer.orders.confirmed.order(created_at: :desc)
    @orders  = Order.confirmed.order(created_at: :desc)
  end

  def week_paramters
    @from_week = params[:from_week].present? ? params[:from_week].to_i : 1
    @to_week = params[:to_week].present? ? params[:to_week].to_i : 0    
  end

  def count_older_orders
    @older_orders_counter = @orders.before(@to_week).count
    
  end

  def weeks_filter
    @orders = @orders.weeks_ago(@from_week, @to_week)
  end
end
