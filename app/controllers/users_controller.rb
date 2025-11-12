class UsersController < ApplicationController
  def index
    users = User.all
    render json: {users:}
  end

  def show
    user = User.find(params[:id])
    render json: {user:}
  end

  def create
    user = User.new(user_params)
    if user.save
      # Send verification email asynchronously
      EmailVerificationJob.perform_later(user.id)
      render json: {
        user: user.slice(:id, :username, :email, :created_at, :updated_at),
        message: "User created successfully. Please check your email to verify your account."
      }, status: :created
    else
      render json: { errors: user.errors.to_hash(true) }, status: :unprocessable_entity
    end
  end

  def verify
    user = User.find_by(verification_token: params[:token])

    if user && !user.email_verified?
      user.update!(email_verified: true, verification_token: nil)
      render json: {
        message: "Email verified successfully!",
        user: user.slice(:id, :username, :email, :email_verified, :created_at, :updated_at)
      }, status: :ok
    else
      render json: { error: "Invalid or expired verification token" }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
