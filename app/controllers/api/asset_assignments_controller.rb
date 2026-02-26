# app/controllers/api/asset_assignments_controller.rb
class Api::AssetAssignmentsController < ApplicationController
  def index
    asset = Asset.find(params[:asset_id])
    render json: asset.asset_assignments.order(created_at: :asc)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset not found" }, status: :not_found
  end

  # Assign (append-only)
  def create
    asset = Asset.find(params[:asset_id])

    active_assignment = asset.asset_assignments.find_by(assigned_to_date: nil)
    if active_assignment.present?
      return render json: {
        error: "This device is already assigned to #{active_assignment.assigned_to}. Please unassign first."
      }, status: :unprocessable_entity
    end

    assignment = AssetAssignment.create!(
      asset: asset,
      assigned_to: assignment_params[:assigned_to],
      assigned_from_date: assignment_params[:assigned_from_date] || Date.today,
      location: assignment_params[:location]
    )

    # Sync asset snapshot
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

  # Unassign / Close assignment
  def close
    asset = Asset.find(params[:asset_id])
    assignment = asset.asset_assignments.find(params[:id])

    if assignment.assigned_to_date.present?
      return render json: { error: "This assignment is already closed." }, status: :unprocessable_entity
    end

    assignment.update!(assigned_to_date: Date.today)

    # Clear snapshot on asset
    asset.update!(
      assigned_to: nil,
      assigned_date: nil
    )

    render json: { message: "Asset unassigned successfully", assignment: assignment }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset or Assignment not found" }, status: :not_found
  end

  private

  def assignment_params
    params.require(:asset_assignment)
          .permit(:assigned_to, :assigned_from_date, :location)
  end
end