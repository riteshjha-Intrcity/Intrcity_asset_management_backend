class Api::DashboardController < ApplicationController
  before_action :require_admin!

  def index
    total_assets = Asset.count

    assigned_assets = Asset.joins(:asset_assignments)
                           .where(asset_assignments: { assigned_to_date: nil })
                           .distinct
                           .count

    available_assets = total_assets - assigned_assets

    # ✅ FIXED HERE
    assets_by_category = Asset.group(:asset_category).count

    total_users = User.count

    users_with_assets = AssetAssignment
                          .where(assigned_to_date: nil)
                          .distinct
                          .count(:assigned_to)

    users_without_assets = total_users - users_with_assets

    recent_assignments = AssetAssignment
                          .includes(:asset)
                          .order(assigned_from_date: :desc)
                          .limit(5)

    render json: {
      success: true,
      data: {
        assets: {
          total: total_assets,
          assigned: assigned_assets,
          available: available_assets,
          by_category: assets_by_category
        },
        users: {
          total: total_users,
          with_assets: users_with_assets,
          without_assets: users_without_assets
        },
        recent_assignments: recent_assignments.map do |a|
          {
            id: a.id,
            assigned_from: a.assigned_from_date,
            assigned_to_date: a.assigned_to_date,
            asset: {
              id: a.asset.id,
              brand: a.asset.brand,
              model: a.asset.model_id
            }
          }
        end
      }
    }
  end
end