class Api::UsersController < ApplicationController
  before_action :require_admin!, only: [:create, :index]

  # GET /api/users (admin only)
  def index
    users = User.select(:id, :name, :emp_id, :email, :gmail, :phone, :joining_date, :role, :created_at)
    render json: users
  end

  # POST /api/users (admin only)
  def create
    user = User.new(user_params)

    if user.save
      render json: user.slice(:id, :name, :emp_id, :email, :gmail, :phone, :joining_date, :role), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/me (admin/user can view self)
  def me
    render json: current_user.slice(:id, :name, :emp_id, :email, :gmail, :phone, :joining_date, :role)
  end

  private

  # ⚠️ TEMP auth (replace later with JWT)
  def current_user
    @current_user ||= User.first
  end

  def require_admin!
    unless current_user&.role == "admin"
      render json: { error: "Admin access required" }, status: :forbidden
    end
  end

  def user_params
    params.require(:user).permit(
      :name,
      :emp_id,
      :email,
      :gmail,
      :phone,
      :joining_date,
      :password,
      :password_confirmation,
      :role
    )
  end
end