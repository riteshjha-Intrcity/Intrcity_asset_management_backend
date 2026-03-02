class AssetAssignment < ApplicationRecord
  belongs_to :asset

STATUSES = ["pending", "assigned", "closed", "rejected"]

  validates :assigned_to, presence: true
  validates :assigned_from_date, presence: true
  validates :status, inclusion: { in: STATUSES }

  validate :only_one_active_assignment, on: :create

  before_create :set_defaults

  private

  def only_one_active_assignment
    if AssetAssignment
         .where(asset_id: asset_id, assigned_to_date: nil)
         .exists?
      errors.add(:base, "Asset is already assigned. Please unassign first.")
    end
  end

  def set_defaults
    self.status ||= "pending"
    self.confirmation_token ||= SecureRandom.hex(20)
  end
end