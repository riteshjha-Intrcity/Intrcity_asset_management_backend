class AddVendorDetailsToAssets < ActiveRecord::Migration[8.1]
  def change
    add_column :assets, :vendor_name, :string
    add_column :assets, :vendor_contact, :string
    add_column :assets, :vendor_email, :string
    add_column :assets, :vendor_address, :text
  end
end
