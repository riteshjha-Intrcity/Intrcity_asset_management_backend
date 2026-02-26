# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authorize_request

  private

  def authorize_request
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last

    return render json: { error: "Missing token" }, status: :unauthorized unless token

    begin
      decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
      @current_user = User.find(decoded[0]["user_id"])
    rescue JWT::DecodeError
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def require_admin!
    render json: { error: "Admin access required" }, status: :forbidden unless current_user&.role == "admin"
  end
end