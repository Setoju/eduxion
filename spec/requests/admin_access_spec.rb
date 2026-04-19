require "rails_helper"

RSpec.describe "Admin access", type: :request do
  let(:permission_message) { "you don't have permission to do this action" }

  describe "GET /admin" do
    it "redirects guests to the main page" do
      get "/admin"

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(permission_message)
    end

    it "redirects signed-in non-admin users to the main page" do
      user = create(:user, role: "student", admin: false)
      sign_in user

      get "/admin"

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(permission_message)
    end

    it "allows signed-in admin users" do
      admin_user = create(:user, role: "student", admin: true)
      sign_in admin_user

      get "/admin"

      expect(response).to have_http_status(:ok)
    end
  end
end