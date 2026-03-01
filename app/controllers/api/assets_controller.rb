class Api::AssetsController < ApplicationController
  before_action :require_admin!, except: [:index, :show]

  # ==========================================
  # OPTIONS
  # ==========================================
  def options
    render json: {
      categories: Asset::ASSET_CATEGORIES,
      statuses: Asset::ASSET_STATUSES,
      locations: Asset::LOCATIONS
    }
  end


  # ==========================================
  # GET /api/assets
  # ==========================================
  def index
    assets = Asset.all

    # 🔥 Assigned / Available filter (IMPORTANT FIX)
    if params[:status] == "assigned"
      assets = Asset.joins(:asset_assignments)
                    .where(asset_assignments: { assigned_to_date: nil })
                    .distinct
    elsif params[:status] == "available"
      assigned_ids = AssetAssignment
                       .where(assigned_to_date: nil)
                       .pluck(:asset_id)

      assets = Asset.where.not(id: assigned_ids)
    else
      # Normal status filter (Working, Under Repair etc.)
      assets = assets.where(asset_status: params[:status]) if params[:status].present?
    end

    assets = assets.where(location: params[:location]) if params[:location].present?
    assets = assets.where(asset_category: params[:category]) if params[:category].present?

    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 20).to_i

    total = assets.count

    assets = assets.order(created_at: :desc)
                   .offset((page - 1) * per_page)
                   .limit(per_page)

    render json: {
      data: assets,
      meta: {
        total: total,
        page: page,
        per_page: per_page
      }
    }
  end


  # ==========================================
  # GET /api/assets/:id
  # ==========================================
  def show
    asset = Asset.find(params[:id])

    render json: asset
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset not found" }, status: :not_found
  end


  # ==========================================
  # POST /api/assets
  # ==========================================
  def create
    asset = Asset.new(asset_params)

    ActiveRecord::Base.transaction do
      asset.save!

      # 🔥 If assigned_to present → create assignment record
      if asset.assigned_to.present?
        AssetAssignment.create!(
          asset: asset,
          assigned_to: asset.assigned_to,
          assigned_from_date: asset.assigned_date || Date.today,
          location: asset.location
        )
      end
    end

    render json: asset, status: :created

  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages },
           status: :unprocessable_entity
  end


  # ==========================================
  # PUT /api/assets/:id
  # ==========================================
  def update
    asset = Asset.find(params[:id])

    ActiveRecord::Base.transaction do

      # 🔥 If assigned_to changed
      if asset_params[:assigned_to].present? &&
         asset.assigned_to != asset_params[:assigned_to]

        # Close existing active assignment
        asset.asset_assignments
             .where(assigned_to_date: nil)
             .update_all(assigned_to_date: Date.today)

        # Create new assignment
        AssetAssignment.create!(
          asset: asset,
          assigned_to: asset_params[:assigned_to],
          assigned_from_date: asset_params[:assigned_date] || Date.today,
          location: asset_params[:location] || asset.location
        )
      end

      asset.update!(asset_params)
    end

    render json: asset

  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset not found" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end


  # ==========================================
  # DELETE /api/assets/:id
  # ==========================================
  def destroy
    asset = Asset.find(params[:id])
    asset.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset not found" }, status: :not_found
  end


  private

  def asset_params
    params.require(:asset).permit(
      :asset_category, :device_type, :brand, :model_id,
      :serial_number, :configuration, :operating_system,
      :purchase_date, :purchase_cost,
      :warranty_years, :warranty_expiry_date,
      :location, :assigned_to, :assigned_date,
      :repairing_date, :repairing_cost,
      :asset_status, :cpu_core
    )
  end
end