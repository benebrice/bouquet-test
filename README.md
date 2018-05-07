# Development environment
## Softwares and versions
* Sublime Text
* Specific usage of `ruby 2.2.6` for Bergamotte to avoid any side effect on other projects (`ruby >= 2.4`)
* SQL console
* Rails console
* Git
 
	The complet workflow can be sent if necessary. It was not published on any web platform like GitHub to preserve privacy and integrity of this test.

# Work reflections
> Any customer browse to an account page and is prompted with a login page

This will be done by using [Devise](https://github.com/plataformatec/devise) and must be the first step.

> Extend ruby Hash Class to use your own implementation of the Hash#dig method without ruby 2.3. Make it available in the Rails app.

This makes me use `ruby 2.2.6`

> We need a weekly summary page

For a customer, a week to display orders is a too short time. This means the current customer logged won't see a lot of relevent data. That's why I choose to display all orders and not only orders linked to the logged user.
This can be updated on the file `app/controllers/orders_controller.rb` on the `analytics` by uncommenting

	service = OrderService.new(current_customer, generate_options) # l.11

# Tasks
1. Check `app/models/customer.rb`
2. Check `app/models/category.rb`
3. Check 

	```
	app/models/customer.rb
	app/controller/
	application_controller.rb
	config/routes.rb
	```
	
4. SQL Query

	```
	SELECT 
		c.id AS 'customer_id',
		c.first_name AS 'customer_first_name',
		cat.id AS 'category_id',
		cat.name AS 'category_name'
	FROM 
		customers c, 
		products p, 
		categories cat, 
		orders o
	WHERE 
		o.customer_id = c.id AND 
		o.product_id = p.id AND 
		cat.id = p.category_id
	LIMIT(1)
	```
5. ActiveRecord usage

	```
	# Returns an Array of Arrays
	# No need to change the following return field names:
	#   - customers.id => customer_id 
	#   - customers.first_name => customer_first_name => category_name
	#   - categories.id => category_id
	#   - categories.name
	#
	# SQL generated query:
	# SELECT customers.id, customers.first_name, categories.id, categories.name 
	# FROM "customers" 
	# INNER JOIN "orders" ON "orders"."customer_id" = "customers"."id" 
	# INNER JOIN "products" ON "products"."id" = "orders"."product_id" 
	# INNER JOIN "categories" ON "categories"."id" = "products"."category_id"
	Customer.joins(orders: {product: :category})
			.pluck('customers.id',
					'customers.first_name',
					'categories.id',
					'categories.name')
	```
	
6. `Hash#dig` implementation:

	```
		lib/core_ext/hash.rb
		config/initializers/
		
		# Usage example
		app/controllers/orders_controller.rb
		
		# h = {my_val_1: {my_val_2: {'my_val_3': 666}}}
		# h.dig(:my_val_1, :my_val_2, :my_val_3)
		# => 666
	```
	
7. Analytics
	1. By products, check:
	
		```
		app/controllers/orders_controller.rb
		app/services/order_service.rb
		app/views/orders/analytics.html.slim
		app/views/orders/analytics_by_products/_table.html.slim
		config/routes.rb
		```
	2. By items, check:
	
		```
		app/controllers/orders_controller.rb
		app/services/order_service.rb
		app/views/orders/analytics.html.slim
		app/views/orders/analytics_by_items/_table.html.slim
		config/routes.rb
		```
	3. Asychronous navigation, check:
	
		```
		app/controllers/orders_controller.rb
		app/views/orders/_navigation_week.html.slim
		app/views/orders/analytics.js.erb
		config/routes.rb
		```
	4. Frequencies display, check:
	
		```
		app/controllers/orders_controller.rb
		app/services/order_service.rb
		app/models/order.rb
		app/views/orders/frequencies.html.slim
		app/views/orders/index.html.slim
		config/routes.rb
		```
	5. Recurrences display, check:
	
		```
		app/controllers/orders_controller.rb
		app/services/order_service.rb
		app/views/orders/frequencies.html.slim
		app/views/orders/index.html.slim
		app/views/orders/recurrence.html.slim
		config/routes.rb
		db/seeds.rb
		```


# Additional questions

1. Subscription

	To have an automatic subscription we might need:

	1. Tables
		
		```
		create_table :subscriptions do |t|
	      t.integer :customer_id, null: false   # Customer reference
	      t.integer :billing_address_id         # Billing address reference
	      t.integer :shipping_address_id        # Shipping address reference
	      t.string :frequency_type, null: false # ie: month
	      t.integer :frequency, null: false     # ie: 2
	      t.datetime :start_at, null: false     # ie: 1st january 2018
	      t.datetime :end_at                    # ie: null => 2 times a month from 1st january until... Update ?
	    end
		```
		
		For this `subscriptions` table, we need an `addresses` table. This one is very important and must be carefully chosen according to the company needs. Here is good inspiration [Here is good inspiration from Stackoverflow](https://stackoverflow.com/a/930818/2616474) 

		As written [Here](https://stackoverflow.com/a/18404431/2616474) quoting the **Universal Postal Union**, there is no standard for addressing schema. Then a well knowledge of the company is required for this table.

		We also need a table to register every validated changes on subscriptions as a guardian of proof/safety. Some gem can do the job. For example [Paper Trail](https://github.com/airblade/paper_trail) is known and tests by Rails community. Also, this tracking is done by customer id. This idea might be interesting if there is any hierarchy between customer (now or in the futur).
		
		
	2. Workers
		
		Those kind of tasks cannot be synchronous. Workers are a good point to achieve them. Workers can be chained which is interesting with the following process:
		1. Cron tasks detect flowers to be sent -> Create BillWorker
		2. BillWorker try to bill the customer. On validation (webhook from Bank ?), it creates the bill and create FlowerSenderWorker. On failure, is sends email to the customer
		3. FlowerSenderWorker schedules the delivery and creates FlowerMailer
		4. FlowerMailer sends email to customer with both receipt and schedule information (link to follow the shipment).
	
	Here are both positive and negative parts of the previous ideas.
	
	3. Pros
	
		* Asynchronous thanks to workers.
		* Higly customizable thanks to a single line per customer per suscription.
		* Relatively simple and fast to implement.
		
	4. Cons
	
		* The table with `n` complexity with the number of customer at minimum (a customer can have several subscriptions which increase complexity).
		* Tests subscripton versioning to be sure there is no regression from a version to another, even if the gem itself is tested because it's a critical part.
		* Might create difficulty if database is 
	
* High traffic

	Several approaches are possible:

	1. Best client first (client paying the highest price every month/year)
	2. Oldest client first (loyalty first)
	3. New client first
	4. Set a max flowers per customer 

# Tests

Tests are made with `rspec` using [factory-bot](https://github.com/thoughtbot/factory_bot) and [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers)
	
Run test with:

	bin/rspec spec/

What is tested:

* models associations (`spec/models`)
* services (`spec/services`)
	* SQL queries
	* SQL response format
	* SQL response data
* controllers (`spec/controllers`)
	* Login // Redirections
	* Rendered views
	* Instances variables required for the views
	
# Code cleaning

Code cleaning was made by using `rubocop` and `reek`

# Improvements
* Add tests for scopes
* Use `Redis` to cache results
* Use workers to calculate results each hour/day/week/month/year