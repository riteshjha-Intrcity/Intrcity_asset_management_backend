class AddStatusAndTokenToAssetAssignments < ActiveRecord::Migration[8.1]
  def change
    add_column :asset_assignments, :status, :string
    add_column :asset_assignments, :confirmation_token, :string
  end
end
