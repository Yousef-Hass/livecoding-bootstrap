class AuthController < ApplicationController
  def login
    user = User.find_by(email: login_params[:email])

    if user&.authenticate(login_params[:password])
      token = generate_jwt_token(user)
      render json: {
        token: token,
        user: user.slice(:id, :username, :email, :created_at, :updated_at)
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def login_params
    params.require(:auth).permit(:email, :password)
  end

  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end
end
