# db/migrate/2026xxxxxx_add_employee_fields_to_users.rb
class AddEmployeeFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :emp_id, :string, null: false
    add_column :users, :joining_date, :date
    add_column :users, :phone, :string
    add_column :users, :gmail, :string

    add_index :users, :emp_id, unique: true
    add_index :users, :gmail, unique: true
  end
end