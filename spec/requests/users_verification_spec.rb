require 'rails_helper'

RSpec.describe "User Verification", type: :request do
  describe "POST /users (with verification)" do
    it "creates user and sends verification email" do
      expect {
        post "/users", params: {
          user: {
            username: "testuser",
            email: "test@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response["message"]).to include("Please check your email to verify")
      expect(json_response["user"]["email"]).to eq("test@example.com")
    end
  end

  describe "GET /users/verify" do
    let(:user) { User.create!(username: "testuser", email: "test@example.com", password: "password123") }

    before do
      user.update!(verification_token: "valid_token_123")
    end

    context "with valid token" do
      it "verifies the user's email" do
        get "/users/verify", params: { token: "valid_token_123" }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Email verified successfully!")
        expect(json_response["user"]["email_verified"]).to be true

        user.reload
        expect(user.email_verified?).to be true
        expect(user.verification_token).to be_nil
      end
    end

    context "with invalid token" do
      it "returns error for invalid token" do
        get "/users/verify", params: { token: "invalid_token" }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Invalid or expired verification token")
      end
    end

    context "with already verified user" do
      before do
        user.update!(email_verified: true)
      end

      it "returns error for already verified user" do
        get "/users/verify", params: { token: "valid_token_123" }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Invalid or expired verification token")
      end
    end
  end
end
