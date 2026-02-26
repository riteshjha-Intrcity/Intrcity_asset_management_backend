class CreateAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :assets do |t|
      t.string :asset_tag

      t.timestamps
    end
  end
end
