# app/controllers/api/assets_controller.rb
class Api::AssetsController < ApplicationController

  # GET /api/assets?status=Working&location=Noida&category=Laptop&page=1&per_page=20
  def index
    assets = Asset.all

    assets = assets.where(asset_status: params[:status]) if params[:status].present?
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

  # GET /api/assets/:id
  def show
    asset = Asset.find(params[:id])
    render json: asset
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset not found" }, status: :not_found
  end

  # POST /api/assets
  def create
    asset = Asset.new(asset_params)

    if asset.save
      # create assignment history if assigned_to present
      if asset.assigned_to.present?
        AssetAssignment.create!(
          asset_id: asset.id,
          assigned_to: asset.assigned_to,
          assigned_from_date: asset.assigned_date || Date.today,
          location: asset.location
        )
      end

      render json: asset, status: :created
    else
      render json: { errors: asset.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/assets/:id
  def update
    asset = Asset.find(params[:id])

    # Track assignment change
    if asset_params[:assigned_to].present? && asset.assigned_to != asset_params[:assigned_to]
      AssetAssignment.create!(
        asset_id: asset.id,
        assigned_to: asset_params[:assigned_to],
        assigned_from_date: asset_params[:assigned_date] || Date.today,
        location: asset_params[:location] || asset.location
      )
    end

    asset.update!(asset_params)
    render json: asset
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset not found" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # DELETE /api/assets/:id
  def destroy
    asset = Asset.find(params[:id])
    asset.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset not found" }, status: :not_found
  end

  private

  # app/controllers/api/assets_controller.rb
def asset_params
  params.require(:asset).permit(
    :asset_tag, :asset_category, :device_type, :brand, :model_id,
    :serial_number, :configuration, :operating_system,
    :purchase_date, :purchase_cost,
    :warranty_years, :warranty_expiry_date,
    :location, :assigned_to, :assigned_date,
    :repairing_date, :repairing_cost,
    :asset_status, :cpu_core
  )
end
end