class OrderService
  attr_reader :analysis_type, 
              :items, 
              :products,
              :from_week,
              :to_week, 
              :options

  def initialize(current_customer, options = {})
    @current_customer = current_customer
    sanitize_type(options.delete(:analysis_type))
    sanitize_options(options)
    load_filters
    init_arrays
  end

  def load_orders
    @orders = find_orders(@options[:global_orders])
    apply_filter
  end

  def load_items
    return if @orders.count.zero?
    @items = @orders.includes(:items).map(&:items).uniq.flatten
  end

  def load_products
    return if @orders.count.zero?
    @products = @orders.includes(:product).map(&:product).uniq
  end

  def load_both
    load_items
    load_products
  end

  def order_before
    @orders.before(@options[:to_week]).count
  end

  def apply_filter
    @orders.weeks_ago(@from_week, @to_week) unless no_filter?
  end

  def no_filter?
    [@options[:from_week], @options[:to_week]].compact.count.zero?
  end

  private

  def find_orders(global = false)
    current_customer.orders
                    .confirmed
                    .order(created_at: :desc) unless global
    Order.confirmed
         .order(created_at: :desc) if global
  end

  def init_arrays
    @orders = Order.none
    @products = nil
    @items = nil
  end

  def sanitize_type(type)
    @analysis_type = ['items', 'products'].include?(type) ? type : 'both'
  end

  def sanitize_options(options)
    options[:from_week] = options[:from_week].present? ? options[:from_week].to_i : 1
    options[:to_week] = options[:to_week].present? ? options[:to_week].to_i : 1
    @options = options
  end

  def load_filters
    @from_week = @options[:from_week]
    @to_week = @options[:to_week]
  end

  class Frequency
    class << self
      def total_orders(with_execution = false)
        sql = "SELECT count(id) AS 'all_orders' FROM orders"
        return sql unless with_execution
        execute_sql(sql) if with_execution
      end

      def total_orders_by_customer_table(with_execution = false)
        sql = "SELECT count(*) AS 'order_count', customer_id
                            FROM orders o
                            GROUP BY customer_id
                            ORDER BY 'order_count'"
        return sql unless with_execution
        execute_sql(sql) if with_execution
      end

      # global_order_count_sql = "SELECT count(id) AS 'all_orders'
      #                           FROM orders 
      #                           WHERE created_at > '#{@from_week.week.ago.utc.to_s(:db)}'
      #                           AND created_at < '#{@to_week.week.ago.utc.to_s(:db)}'"
      def frequencies_table(with_execution = false)
        sql = "SELECT order_count, count(*) AS 'customer_count', (#{total_orders}) AS 'total_orders'
              FROM
                (#{total_orders_by_customer_table})
              GROUP BY order_count
              ORDER BY order_count"
        return sql unless with_execution
        execute_sql(sql) if with_execution
      end

      def execute_sql(sql)
        ActiveRecord::Base.connection.execute(sql)
      end
    end
  end

  class Recurrence
    class << self
      def orders_by_customer_by_month_table(with_execution = false)
        sql = "SELECT CAST(strftime('%m', datetime(created_at)) as int) as order_month, customer_id, count(*) as total_customer_order
                                    FROM orders o1  
                                    GROUP BY customer_id, order_month"
        return sql unless with_execution
        execute_sql(sql) if with_execution
      end

      def customer_first_order_table(with_execution = false)
        sql = "SELECT customer_id, min(created_at) AS 'first_order_on_month'
                                FROM orders
                                group by customer_id"
        return sql unless with_execution
        execute_sql(sql) if with_execution
      end

      def recurrences_table(with_execution = false)
        sql = "SELECT order_month, count(*) as 'recurrence_customers', sum(total_orders) as 'orders_on_month'
              FROM
                (SELECT order_month, A.customer_id, sum(total_customer_order) AS 'total_orders', first_order_on_month
                  FROM 
                    (#{orders_by_customer_by_month_table}) A
                  LEFT JOIN
                    (#{customer_first_order_table}) B
                  ON A.customer_id = B.customer_id
                  GROUP BY order_month, A.customer_id)
              GROUP BY order_month
              HAVING COUNT(CAST(strftime('%m', datetime(first_order_on_month)) as int) < order_month)"
        return sql unless with_execution
        execute_sql(sql) if with_execution
      end

      def execute_sql(sql)
        ActiveRecord::Base.connection.execute(sql)
      end
    end
  end
end