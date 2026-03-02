class Api::AssetAssignmentsController < ApplicationController
  before_action :require_admin!, except: [ :confirm ]
  before_action :set_asset, except: [ :confirm ]

  # ==========================================
  # GET /api/assets/:asset_id/asset_assignments
  # ==========================================
  def index
    assignments = @asset.asset_assignments
                        .order(assigned_from_date: :asc)

    render json: assignments
  end

  # ==========================================
  # POST /api/assets/:asset_id/asset_assignments
  # Assign (append-only)
  # ==========================================
  def create
    active_assignment = @asset.asset_assignments.find_by(assigned_to_date: nil)

    if active_assignment.present?
      return render json: {
        error: "This device is already assigned to #{active_assignment.assigned_to}. Please unassign first."
      }, status: :unprocessable_entity
    end

    assignment = AssetAssignment.create!(
      asset: @asset,
      assigned_to: params[:asset_assignment][:assigned_to],
      assigned_from_date: Date.today,
      location: params[:asset_assignment][:location],
      status: "pending"
    )

    # 🔥 Send confirmation email
    AssetAssignmentMailer.assignment_email(assignment).deliver_later

    # Update asset snapshot
    @asset.update!(
      assigned_to: assignment.assigned_to,
      assigned_date: assignment.assigned_from_date,
      location: assignment.location
    )

    render json: assignment, status: :created
  end

  # ==========================================
  # GET /api/asset_assignments/confirm
  # ==========================================
  def confirm
    assignment = AssetAssignment.find_by(
      confirmation_token: params[:token]
    )

    return render json: { error: "Invalid token" }, status: :not_found unless assignment

    if assignment.status == "assigned"
      return render json: { message: "Already confirmed" }
    end

    assignment.update!(status: "assigned")

    render json: { message: "Assignment confirmed successfully" }
  end

  # ==========================================
  # PATCH /api/assets/:asset_id/asset_assignments/:id/close
  # ==========================================
  def close
    assignment = @asset.asset_assignments.find(params[:id])

    if assignment.assigned_to_date.present?
      return render json: {
        error: "This assignment is already closed."
      }, status: :unprocessable_entity
    end

    assignment.update!(
      assigned_to_date: Date.today,
      status: "closed"
    )

    @asset.update!(
      assigned_to: nil,
      assigned_date: nil
    )

    render json: {
      message: "Asset unassigned successfully",
      assignment: assignment
    }
  end

  private

  def set_asset
    @asset = Asset.find(params[:asset_id])
  end
end
