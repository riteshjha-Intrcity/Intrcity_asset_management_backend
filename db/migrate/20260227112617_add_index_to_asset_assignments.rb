class AddIndexToAssetAssignments < ActiveRecord::Migration[8.1]
  def change

    add_index :asset_assignments, :assigned_to_date
  end
end