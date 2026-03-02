class Api::AssetsController < ApplicationController
  before_action :require_admin!, except: [ :index, :show ]

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
    assets = Asset.includes(:asset_assignments)

    # 🔥 Assigned / Available filter
    if params[:status] == "assigned"
      assets = assets.joins(:asset_assignments)
                     .where(asset_assignments: { assigned_to_date: nil })
                     .distinct
    elsif params[:status] == "available"
      assigned_ids = AssetAssignment
                       .where(assigned_to_date: nil)
                       .pluck(:asset_id)

      assets = assets.where.not(id: assigned_ids)
    else
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

    # 🔥 Attach assignment_status
    assets_with_status = assets.map do |asset|
      active_assignment = asset.asset_assignments
                               .where(assigned_to_date: nil)
                               .order(created_at: :desc)
                               .first

      asset.as_json.merge(
        assignment_status: active_assignment&.status
      )
    end

    render json: {
      data: assets_with_status,
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
    asset = Asset.includes(:asset_assignments).find(params[:id])

    active_assignment = asset.asset_assignments
                             .where(assigned_to_date: nil)
                             .order(created_at: :desc)
                             .first

    render json: asset.as_json.merge(
      assignment_status: active_assignment&.status
    )

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

      if asset.assigned_to.present?
        AssetAssignment.create!(
          asset: asset,
          assigned_to: asset.assigned_to,
          assigned_from_date: asset.assigned_date || Date.today,
          location: asset.location,
          status: "pending" # 🔥 default status
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
      if asset_params[:assigned_to].present? &&
         asset.assigned_to != asset_params[:assigned_to]

        # Close existing assignment
        asset.asset_assignments
             .where(assigned_to_date: nil)
             .update_all(
               assigned_to_date: Date.today,
               status: "closed"
             )

        # Create new pending assignment
        AssetAssignment.create!(
          asset: asset,
          assigned_to: asset_params[:assigned_to],
          assigned_from_date: asset_params[:assigned_date] || Date.today,
          location: asset_params[:location] || asset.location,
          status: "pending"
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
      :asset_status, :cpu_core,
      :vendor_name,
      :vendor_contact,
      :vendor_email,
      :vendor_address
    )
  end
end
