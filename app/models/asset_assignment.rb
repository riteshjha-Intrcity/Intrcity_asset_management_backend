class AssetAssignment < ApplicationRecord
  belongs_to :asset

  # Must always have assigned_to
  validates :assigned_to, presence: true
  validates :assigned_from_date, presence: true

  validate :only_one_active_assignment, on: :create

  private

  def only_one_active_assignment
    if AssetAssignment
         .where(asset_id: asset_id, assigned_to_date: nil)
         .exists?
      errors.add(:base, "Asset is already assigned. Please unassign first.")
    end
  end
end