class AddFirstNameOnCustomers < ActiveRecord::Migration
  def up
    add_column :customers, :first_name, :string
  end

  def down
    remove_column :customers, :first_name
  end
end
