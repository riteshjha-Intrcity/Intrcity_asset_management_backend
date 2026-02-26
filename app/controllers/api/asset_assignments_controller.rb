# app/controllers/api/asset_assignments_controller.rb
class Api::AssetAssignmentsController < ApplicationController
  def index
    asset = Asset.find(params[:asset_id])
    render json: asset.asset_assignments.order(created_at: :asc)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset not found" }, status: :not_found
  end

  def create
    asset = Asset.find(params[:asset_id])   # 👈 ensure asset exists

    # Close previous assignment
    asset.asset_assignments.where(assigned_to_date: nil).update_all(assigned_to_date: Date.today)

    assignment = AssetAssignment.create!(
      asset: asset,   # 👈 attach asset properly
      assigned_to: assignment_params[:assigned_to],
      assigned_from_date: assignment_params[:assigned_from_date] || Date.today,
      assigned_to_date: assignment_params[:assigned_to_date],
      location: assignment_params[:location]
    )

    # Sync asset table (current assignee snapshot)
    asset.update!(
      assigned_to: assignment.assigned_to,
      assigned_date: assignment.assigned_from_date,
      location: assignment.location
    )

    render json: assignment, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Asset not found" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def assignment_params
    params.require(:asset_assignment)
          .permit(:assigned_to, :assigned_from_date, :assigned_to_date, :location)
  end
end