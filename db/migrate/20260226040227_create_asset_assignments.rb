class CreateAssetAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :asset_assignments do |t|
      t.references :asset, null: false, foreign_key: true
      t.string :assigned_to
      t.date :assigned_from_date
      t.date :assigned_to_date
      t.string :location

      t.timestamps
    end
  end
end
