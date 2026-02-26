# db/migrate/XXXXXXXXXXXXXX_add_fields_to_assets.rb
class AddFieldsToAssets < ActiveRecord::Migration[8.1]
  def change
    change_table :assets do |t|
      t.string  :asset_category
      t.string  :device_type
      t.string  :brand
      t.string  :model_id
      t.string  :serial_number
      t.string  :configuration
      t.string  :operating_system
      t.date    :purchase_date
      t.integer :purchase_cost

      # Warranty: store years + optional expiry date
      t.integer :warranty_years          # e.g. 3, 4, 5
      t.date    :warranty_expiry_date

      t.string  :location
      t.string  :assigned_to             # EMP1023 - name handled in frontend/HR table
      t.date    :assigned_date

      t.date    :repairing_date
      t.integer :repairing_cost

      t.string  :asset_status            # Working / Under Repair / Dead
      t.string  :cpu_core                # CORE I3 / I5 etc (nullable for non-EUC assets)
    end

    add_index :assets, :asset_tag, unique: true
    add_index :assets, :serial_number, unique: true
    add_index :assets, :asset_category
    add_index :assets, :asset_status
    add_index :assets, :location
  end
end