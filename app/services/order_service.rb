# Order service to generate
#  - Analysis of orders
#  - Frequencies on orders
#  - Reccurences on orders
class OrderService
  attr_reader :items,
              :products,
              :options

  def initialize(current_customer, options = {})
    @current_customer = current_customer
    @options = self.class.sanitize_options(options)
    @orders = Order.none
  end

  def load_orders
    @orders = find_orders
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

  def load_all
    load_items
    load_products
  end

  def order_before
    @orders.before(@options[:to_week]).count
  end

  def apply_filter
    @orders.weeks_ago(*@options.values_at(:from_week, :to_week)) unless no_filter?
  end

  def no_filter?
    @options.values_at(:from_week, :to_week).compact.count.zero?
  end 

  private

  def find_orders
    if @current_customer
      return current_customer.orders
                             .confirmed
                             .order(created_at: :desc)
    end

    Order.confirmed
         .order(created_at: :desc)
  end

  class << self
    def sanitize_options(options)
      type = options[:analysis_type]
      options[:analysis_type] = %w[items products].include?(type) ? type : 'all'
      sanitize_date_filter(options, [{ param_name: :from_week, default_value: 1 },
                                     { param_name: :to_week, default_value: 0 }])
    end

    def sanitize_date_filter(options, params)
      params.each do |param_hash|
        param_name = param_hash[:param_name]
        options[param_name] = integer_with_default_value(options[param_name], param_hash[:default_value])
      end
      options
    end

    def integer_with_default_value(val, default_val)
      val ? val.to_i : default_val
    end
  end

  # Generate frequancies table from orders
  class Frequency
    class << self
      # global_order_count_sql = "SELECT count(id) AS 'all_orders'
      #                           FROM orders
      #                           WHERE created_at > '#{@from_week.week.ago.utc.to_s(:db)}'
      #                           AND created_at < '#{@to_week.week.ago.utc.to_s(:db)}'"
      def frequencies_table
        sql = "SELECT order_count, count(*) AS 'customer_count', (#{total_orders}) AS 'total_orders'
              FROM
                (#{total_orders_by_customer_table})
              GROUP BY order_count
              ORDER BY order_count"
        execute_sql(sql)
      end

      def execute_sql(sql)
        ActiveRecord::Base.connection.execute(sql)
      end

      private

      def total_orders
        "SELECT count(id) AS 'all_orders' FROM orders"
      end

      def total_orders_by_customer_table
        "SELECT count(*) AS 'order_count', customer_id
         FROM orders o
         GROUP BY customer_id
         ORDER BY 'order_count'"
      end
    end
  end

  # Generate recurrences tbale from orders
  class Recurrence
    class << self
      def recurrences_table
        sql = "SELECT order_month, count(*) as 'recurrence_customers', sum(total_orders) as 'orders_on_month'
              FROM
                (#{customer_orders_by_months_table})
              GROUP BY order_month
              HAVING COUNT(CAST(strftime('%m', datetime(first_order_on_month)) as int) < order_month)"
        execute_sql(sql)
      end

      def execute_sql(sql)
        ActiveRecord::Base.connection.execute(sql)
      end

      private

      def orders_by_customer_by_month_table
        "SELECT CAST(strftime('%m', datetime(created_at)) as int) as order_month,
                customer_id,
                count(*) as total_customer_order
         FROM orders o1
         GROUP BY customer_id, order_month"
      end

      def customer_first_order_table
        "SELECT customer_id, min(created_at) AS 'first_order_on_month'
                                FROM orders
                                group by customer_id"
      end

      def customer_orders_by_months_table
        "SELECT order_month, A.customer_id, sum(total_customer_order) AS 'total_orders', first_order_on_month
         FROM
          (#{orders_by_customer_by_month_table}) A
         LEFT JOIN
          (#{customer_first_order_table}) B
         ON A.customer_id = B.customer_id
         GROUP BY order_month, A.customer_id"
      end
    end
  end
end
