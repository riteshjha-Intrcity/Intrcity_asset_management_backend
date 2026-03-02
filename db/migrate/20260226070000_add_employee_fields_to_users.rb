
class AddEmployeeFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :emp_id, :string
    add_column :users, :joining_date, :date
    add_column :users, :phone, :string
    add_column :users, :gmail, :string

    add_index :users, :emp_id, unique: true
  end
end
