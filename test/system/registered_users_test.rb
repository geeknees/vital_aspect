require "application_system_test_case"

class RegisteredUsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:owner)
  end

  def sign_in(user)
    visit new_session_path(locale: "en")
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text "Dashboard", wait: 5
  end

  test "create new user from index" do
    sign_in(@user)
    visit registered_users_path(locale: "en")

    click_on "New User"
    fill_in "user_email_address", with: "newuser@example.com"
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    click_on "Create User"

    assert_text "User was successfully created."
    assert_text "newuser@example.com"
  end
end
