# app/controllers/api/auth_controller.rb
class Api::AuthController < ApplicationController
  skip_before_action :authorize_request, only: [:login]

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = encode_token({ user_id: user.id })
      render json: {
        token: token,
        user: user.slice(:id, :name, :emp_id, :email, :role)
      }
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def encode_token(payload)
    JWT.encode(payload, Rails.application.secret_key_base, "HS256")
  end
end