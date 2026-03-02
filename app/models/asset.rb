# app/models/asset.rb
class Asset < ApplicationRecord
  has_many :asset_assignments, dependent: :destroy

  before_create :generate_asset_tag
  before_save :set_warranty_expiry_date

  ASSET_CATEGORIES = %w[
    Server Laptop Macbook Android iOS Router Switch CCTV AccessPoint Printer TV AudioSystems Desktop
  ]

  ASSET_STATUSES = [ "Working", "Under Repair", "Dead" ]

  LOCATIONS = [ "Noida", "Delhi", "Kochi", "LKO", "Lounge" ]

  validates :asset_tag, uniqueness: true
  validates :asset_category, inclusion: { in: ASSET_CATEGORIES }, allow_blank: true
  validates :asset_status, inclusion: { in: ASSET_STATUSES }, allow_blank: true
  validates :location, inclusion: { in: LOCATIONS }, allow_blank: true
  validates :serial_number, uniqueness: true, allow_blank: true
  validates :vendor_email,
          format: { with: URI::MailTo::EMAIL_REGEXP },
          allow_blank: true

  # EUC assets only (Laptop/Mobile)
  def euc_asset?
    %w[Laptop Macbook Android iOS Desktop].include?(asset_category)
  end

  private

  def set_warranty_expiry_date
    return unless purchase_date.present? && warranty_years.present?

    self.warranty_expiry_date = purchase_date + warranty_years.years
  end

  def generate_asset_tag
    last_tag = Asset.lock
                    .where("asset_tag LIKE ?", "AST-%")
                    .order(:created_at)
                    .last
                    &.asset_tag

    last_number =
      if last_tag.present?
        last_tag.split("-").last.to_i
      else
        0
      end

    self.asset_tag = format("AST-%04d", last_number + 1)
  end
end
