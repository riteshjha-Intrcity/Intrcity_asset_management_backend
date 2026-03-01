class Api::AssetAssignmentsController < ApplicationController
  before_action :require_admin!
  before_action :set_asset

  # ==========================================
  # GET /api/assets/:asset_id/asset_assignments
  # ==========================================
  def index
    assignments = @asset.asset_assignments
                        .order(assigned_from_date: :asc)

    render json: assignments
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset not found" }, status: :not_found
  end


  # ==========================================
  # POST /api/assets/:asset_id/asset_assignments
  # Assign (append-only)
  # ==========================================
  def create
  asset = Asset.find(params[:asset_id])

  assignment_params = params.require(:asset_assignment)
                            .permit(:assigned_to, :location)

  active_assignment = asset.asset_assignments.find_by(assigned_to_date: nil)
  if active_assignment.present?
    return render json: {
      error: "This device is already assigned to #{active_assignment.assigned_to}. Please unassign first."
    }, status: :unprocessable_entity
  end

  assignment = AssetAssignment.create!(
    asset_id: asset.id,
    assigned_to: assignment_params[:assigned_to],
    assigned_from_date: Date.today,
    location: assignment_params[:location]
  )

  # Sync snapshot
  asset.update!(
    assigned_to: assignment.assigned_to,
    assigned_date: assignment.assigned_from_date,
    location: assignment.location
  )

  render json: assignment, status: :created

rescue ActiveRecord::RecordNotFound
  render json: { error: "Asset not found" }, status: :not_found
rescue ActiveRecord::RecordInvalid => e
  render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
end
  


  # ==========================================
  # PATCH /api/assets/:asset_id/asset_assignments/:id/close
  # Close / Unassign
  # ==========================================
  def close
    assignment = @asset.asset_assignments.find(params[:id])

    if assignment.assigned_to_date.present?
      return render json: {
        error: "This assignment is already closed."
      }, status: :unprocessable_entity
    end

    assignment.update!(assigned_to_date: Date.today)

    # 🔥 Clear snapshot on asset
    @asset.update!(
      assigned_to: nil,
      assigned_date: nil
    )

    render json: {
      message: "Asset unassigned successfully",
      assignment: assignment
    }

  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset or Assignment not found" },
           status: :not_found
  end


  private

  def set_asset
    @asset = Asset.find(params[:asset_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset not found" }, status: :not_found
  end

  def assignment_params
    params.require(:asset_assignment)
          .permit(:assigned_to, :assigned_from_date, :location)
  end
end