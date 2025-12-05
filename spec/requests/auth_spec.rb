require 'rails_helper'

RSpec.describe "Auth", type: :request do
  describe "POST /auth/login" do
    let(:user) { User.create!(username: "testuser", email: "test@example.com", password: "password123") }

    context "with valid credentials" do
      it "returns token and user data" do
        post "/auth/login", params: {
          auth: {
            email: user.email,
            password: "password123"
          }
        }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("token")
        expect(json_response).to have_key("user")
        expect(json_response["user"]["email"]).to eq(user.email)
        expect(json_response["user"]["username"]).to eq(user.username)
      end
    end

    context "with invalid email" do
      it "returns unauthorized error" do
        post "/auth/login", params: {
          auth: {
            email: "wrong@example.com",
            password: "password123"
          }
        }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Invalid email or password")
      end
    end

    context "with invalid password" do
      it "returns unauthorized error" do
        post "/auth/login", params: {
          auth: {
            email: user.email,
            password: "wrongpassword"
          }
        }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Invalid email or password")
      end
    end

    context "with missing parameters" do
      it "returns error for missing email" do
        post "/auth/login", params: {
          auth: {
            password: "password123"
          }
        }

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
