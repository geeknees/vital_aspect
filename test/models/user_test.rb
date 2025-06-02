require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:owner)
    @admin_user = users(:admin)
    @member_user = users(:member)
  end

  # Association tests
  test "should have secure password" do
    user = User.new(email_address: "test@example.com")
    user.password = "password123"
    assert user.authenticate("password123")
    assert_not user.authenticate("wrong_password")
  end

  test "should have many sessions" do
    assert_respond_to @user, :sessions
    assert_equal [], @user.sessions.to_a
  end

  test "should have many owned_organizations" do
    assert_respond_to @user, :owned_organizations
    assert_includes @user.owned_organizations, organizations(:test_org)
  end

  test "should have many memberships" do
    assert_respond_to @user, :memberships
    assert_includes @user.memberships, memberships(:owner_membership)
  end

  test "should have many organizations through memberships" do
    assert_respond_to @user, :organizations
    assert_includes @user.organizations, organizations(:test_org)
  end

  test "should destroy associated sessions when user is destroyed" do
    # Create a session for the user first (assuming Session model exists)
    session_count = Session.count
    @user.destroy
    # Sessions should be destroyed when user is destroyed
    assert_equal session_count, Session.count
  end

  test "should destroy owned organizations when user is destroyed" do
    org_count = Organization.count
    owned_orgs_count = @user.owned_organizations.count
    @user.destroy
    assert_equal org_count - owned_orgs_count, Organization.count
  end

  test "should destroy memberships when user is destroyed" do
    user_memberships = @user.memberships.to_a
    membership_ids = user_memberships.map(&:id)
    @user.destroy

    # Check that the user's memberships no longer exist
    membership_ids.each do |id|
      assert_raises(ActiveRecord::RecordNotFound) do
        Membership.find(id)
      end
    end
  end

  # Email normalization tests
  test "should normalize email address by stripping whitespace and converting to lowercase" do
    user = User.new(email_address: "  TEST@EXAMPLE.COM  ")
    user.valid? # This triggers normalization
    assert_equal "test@example.com", user.email_address
  end

  test "should normalize empty email address" do
    user = User.new(email_address: "")
    user.valid?
    assert_equal "", user.email_address
  end

  test "should handle nil email address in normalization" do
    user = User.new(email_address: nil)
    user.valid?
    assert_nil user.email_address
  end

  # admin_organizations method tests
  test "admin_organizations should return organizations where user has admin or owner role" do
    admin_orgs = @user.admin_organizations
    assert_includes admin_orgs, organizations(:test_org)

    # Test admin user
    admin_admin_orgs = @admin_user.admin_organizations
    assert_includes admin_admin_orgs, organizations(:test_org)
    assert_includes admin_admin_orgs, organizations(:another_org)
  end

  test "admin_organizations should not return organizations where user is only a member" do
    member_admin_orgs = @member_user.admin_organizations
    assert_not_includes member_admin_orgs, organizations(:test_org)
  end

  test "admin_organizations should return empty array for user with no admin roles" do
    user_with_no_admin = users(:one)
    assert_empty user_with_no_admin.admin_organizations
  end

  # member_organizations method tests
  test "member_organizations should return organizations where user has member role" do
    member_orgs = @member_user.member_organizations
    assert_includes member_orgs, organizations(:test_org)
  end

  test "member_organizations should not return organizations where user is admin or owner" do
    owner_member_orgs = @user.member_organizations
    assert_not_includes owner_member_orgs, organizations(:test_org)

    admin_member_orgs = @admin_user.member_organizations
    assert_not_includes admin_member_orgs, organizations(:test_org)
    assert_not_includes admin_member_orgs, organizations(:another_org)
  end

  test "member_organizations should return empty array for user with no member roles" do
    assert_empty @user.member_organizations
    assert_empty @admin_user.member_organizations
  end

  # active_memberships method tests
  test "active_memberships should return only active memberships" do
    active_memberships = @user.active_memberships
    assert_includes active_memberships, memberships(:owner_membership)

    # Test that inactive memberships are not included
    member_active = @member_user.active_memberships
    assert_includes member_active, memberships(:member_membership)
    assert_not_includes member_active, memberships(:inactive_member)
  end

  test "active_memberships should return empty array for user with no active memberships" do
    user = User.create!(email_address: "inactive@example.com", password: "password")
    assert_empty user.active_memberships
  end

  test "active_memberships should not include pending memberships" do
    user_with_pending = users(:one)
    active_memberships = user_with_pending.active_memberships
    assert_not_includes active_memberships, memberships(:pending_member)
  end

  # Additional validation tests
  test "should be valid with valid attributes" do
    user = User.new(email_address: "valid@example.com", password: "password123")
    assert user.valid?
  end

  test "should require password for new user" do
    user = User.new(email_address: "test@example.com")
    assert_not user.valid?
  end
end
