This is a coding exercise used by Bergamotte for technical recruitment purposes. There are no limit of time to perform this task nor any particular restriction, however, please spend no more than six consecutive hours.

## Instructions

Please send a zip archive containing your code and any relevant materials in an email along with your resume and motivations to [jobs@bergamotte.com](jobs@bergamotte.com). Include a readme file explaining your assumptions, providing any necessary assumptions, and stating  what you would accomplish with more time.

The purpose of this test is to verify your abilities to code and see how you architecture an application, so this is the time to show everything you know that is applicable and relevant.

Read through the exercise background, try completing as many tasks and additional questions as you can.

Finally, please note that even if you have questions about the test we will not answer them, do what you think is best.

Thank you for committing this time and effort, we are looking forward to seeing  your results.

## Exercise background

We have a (very) basic e-commerce platform, with the four models (Product, Order, Item and ProductItem). You can find the relationships (if not figured already) in the models files and the database design in the schema file.

## Tasks

Please implement the following  stories.

1. An order belongs to a Customer.

2. A product belongs to a Category.

3. Any customer browse to an account page and is prompted with a login page. They enter their credentials (login and password) and are presented with exactly their orders (sorted by status).

4. Write a SQL query to return the results as display below:

***Example***

customer_id | customer_first_name | category_id | category_name
--- | --- | --- | --- | ---
1 |John | 1 | Bouquets

5. Use active record methods to achieve the result above.

6. Extend ruby Hash Class to use your own implementation of the [Hash#dig](http://ruby-doc.org/core-2.3.0_preview1/Hash.html#method-i-dig) method without ruby 2.3. Make it available in the Rails app.

7. Analytics

  *We need a weekly summary page displaying:*
  1. Breakdown by product of sold quantities (based on orders.created_at)
  2. Breakdown by items of sold quantities (based on orders.created_at)
  3. Add asynchronous navigation to change the displayed week
  4. Display order uniq customer count by number of orders (example 1)
  5. (*On a separate view*) Display repartition between reccuring and new customers for each month (example 2)

***Example 1***

Orders|Customers|Percentage
----|----|----
1 order|70|70%
2 orders|20|20%
3 orders|5|5%

***Example 2***

Month|Reccuring Customer|New customer|Total
----|----|----|----
June 2016|0|800|800
July 2016|15|290|305

# Additional questions
*No coding necessary, explain the concept or sketch your thoughts.*

- We want to add a subscription feature to allow our customers to receive flower automaticaly. How would you design the tables, what are the pros and cons of your approach?

- When facing a high traffic and limited supply, how do you distribute the stock among clients checking out?
