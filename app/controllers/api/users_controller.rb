# app/controllers/api/users_controller.rb
class Api::UsersController < ApplicationController
  skip_before_action :authorize_request, only: [:create]
  before_action :require_admin!, only: [:index]

  def index
    render json: User.select(:id, :name, :emp_id, :email, :gmail, :phone, :joining_date, :role)
  end

  def destroy
  user = User.find(params[:id])

  # safety: prevent delete if user has active assigned asset
  if Asset.exists?(assigned_to: user.emp_id)
    return render json: { error: "Cannot delete user with assigned asset" }, status: :unprocessable_entity
  end

  user.destroy
  head :no_content
end

  def create
    # 🚨 Bootstrap logic
    if User.exists?
      # If users already exist, require admin token
      authorize_request
      require_admin!
    end

    user = User.new(user_params)

    if user.save
      render json: user.slice(:id, :name, :emp_id, :email, :role), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def me
    render json: current_user.slice(:id, :name, :emp_id, :email, :gmail, :phone, :joining_date, :role)
  end

  private

  def user_params
    params.require(:user).permit(
      :name, :emp_id, :email, :gmail, :phone, :joining_date,
      :password, :password_confirmation, :role
    )
  end
end