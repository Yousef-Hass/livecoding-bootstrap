class EmailVerificationJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    # Generate verification token if not present
    user.update!(verification_token: SecureRandom.urlsafe_base64(32)) unless user.verification_token

    # Send verification email using the mock MailerAPI
    MailerAPI.send_verification_email(user)
  end
end
