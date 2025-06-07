require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:owner)
  end

  test "user can update email address" do
    # sign in
    post session_path(locale: :en), params: {
      email_address: @user.email_address,
      password: "password"
    }

    patch user_path(locale: :en), params: { user: { email_address: "new@example.com" } }
    assert_redirected_to edit_user_path(locale: :en)
    @user.reload
    assert_equal "new@example.com", @user.email_address
  end
end
