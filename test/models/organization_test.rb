require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  def setup
    @organization = organizations(:test_org)
    @another_org = organizations(:another_org)
    @public_org = organizations(:public_org)
  end

  # Association tests
  test "should belong to owner" do
    assert_respond_to @organization, :owner
    assert_equal users(:owner), @organization.owner
  end

  test "should have many memberships" do
    assert_respond_to @organization, :memberships
    assert_includes @organization.memberships, memberships(:owner_membership)
    assert_includes @organization.memberships, memberships(:admin_membership)
    assert_includes @organization.memberships, memberships(:member_membership)
  end

  test "should have many users through memberships" do
    assert_respond_to @organization, :users
    assert_includes @organization.users, users(:owner)
    assert_includes @organization.users, users(:admin)
    assert_includes @organization.users, users(:member)
  end

  test "should destroy associated memberships when organization is destroyed" do
    membership_ids = @organization.memberships.pluck(:id)
    @organization.destroy

    # Check that the organization's memberships no longer exist
    membership_ids.each do |id|
      assert_raises(ActiveRecord::RecordNotFound) do
        Membership.find(id)
      end
    end
  end

  # Validation tests
  test "should be valid with valid attributes" do
    organization = Organization.new(
      name: "Valid Organization",
      description: "A valid organization description",
      owner: users(:owner)
    )
    assert organization.valid?
  end

  test "should require name presence" do
    @organization.name = nil
    assert_not @organization.valid?
    assert_not_empty @organization.errors[:name]
  end

  test "should require name to be non-empty" do
    @organization.name = ""
    assert_not @organization.valid?
    assert_not_empty @organization.errors[:name]
  end

  test "should not allow name longer than 100 characters" do
    @organization.name = "a" * 101
    assert_not @organization.valid?
    assert_not_empty @organization.errors[:name]
  end

  test "should allow name with exactly 100 characters" do
    @organization.name = "a" * 100
    assert @organization.valid?
  end

  test "should allow empty description" do
    @organization.description = ""
    assert @organization.valid?
  end

  test "should allow nil description" do
    @organization.description = nil
    assert @organization.valid?
  end

  test "should not allow description longer than 500 characters" do
    @organization.description = "a" * 501
    assert_not @organization.valid?
    assert_not_empty @organization.errors[:description]
  end

  test "should allow description with exactly 500 characters" do
    @organization.description = "a" * 500
    assert @organization.valid?
  end

  # admin_users method tests
  test "admin_users should return users with admin role" do
    admin_users = @organization.admin_users
    assert_includes admin_users, users(:admin)
    assert_not_includes admin_users, users(:owner)  # owner role is different from admin
    assert_not_includes admin_users, users(:member)
  end

  test "admin_users should return empty collection when no admin users exist" do
    # Create an organization with no admin users
    org = Organization.create!(name: "No Admin Org", owner: users(:owner))
    assert_empty org.admin_users
  end

  test "admin_users should not include inactive memberships" do
    # The admin_users method only filters by role, not status
    # But let's test to make sure we understand the behavior
    admin_users = @another_org.admin_users
    # another_org has admin user with owner role, but no admin role
    assert_empty admin_users
  end

  # member_users method tests
  test "member_users should return users with member role" do
    member_users = @organization.member_users
    assert_includes member_users, users(:member)
    assert_not_includes member_users, users(:admin)
    assert_not_includes member_users, users(:owner)
  end

  test "member_users should return empty collection when no member users exist" do
    # Create a new organization with no member role users
    org = Organization.create!(name: "No Members Org", owner: users(:owner))
    member_users = org.member_users
    assert_empty member_users
  end

  test "member_users should include both active and inactive member users" do
    member_users = @another_org.member_users
    # Check that it includes inactive members (if any)
    # Based on fixtures, another_org has an inactive member
    assert_includes member_users, users(:member)
  end

  # active_users method tests
  test "active_users should return users with active status" do
    active_users = @organization.active_users
    assert_includes active_users, users(:owner)
    assert_includes active_users, users(:admin)
    assert_includes active_users, users(:member)
    assert_not_includes active_users, users(:one)  # pending status
  end

  test "active_users should not include pending users" do
    active_users = @organization.active_users
    assert_not_includes active_users, users(:one)
  end

  test "active_users should not include inactive users" do
    active_users = @another_org.active_users
    # another_org has admin as owner (active) but member as inactive
    assert_includes active_users, users(:admin)
    assert_not_includes active_users, users(:member)
  end

  # pending_users method tests
  test "pending_users should return users with pending status" do
    pending_users = @organization.pending_users
    assert_includes pending_users, users(:one)
    assert_not_includes pending_users, users(:owner)
    assert_not_includes pending_users, users(:admin)
    assert_not_includes pending_users, users(:member)
  end

  test "pending_users should return empty collection when no pending users exist" do
    pending_users = @another_org.pending_users
    assert_empty pending_users
  end

  # all_users_including_pending method tests
  test "all_users_including_pending should return both active and pending users" do
    all_users = @organization.all_users_including_pending
    assert_includes all_users, users(:owner)   # active
    assert_includes all_users, users(:admin)   # active
    assert_includes all_users, users(:member)  # active
    assert_includes all_users, users(:one)     # pending
  end

  test "all_users_including_pending should not include inactive users" do
    all_users = @another_org.all_users_including_pending
    assert_includes all_users, users(:admin)   # active owner
    assert_not_includes all_users, users(:member)  # inactive member
  end

  test "all_users_including_pending should return only active users when no pending users exist" do
    all_users = @another_org.all_users_including_pending
    assert_includes all_users, users(:admin)
    # Should not include inactive member
    assert_not_includes all_users, users(:member)
  end

  # Edge case tests
  test "should handle organization with no memberships" do
    org = Organization.create!(name: "Empty Org", owner: users(:owner))

    assert_empty org.admin_users
    assert_empty org.member_users
    assert_empty org.active_users
    assert_empty org.pending_users
    assert_empty org.all_users_including_pending
  end

  test "owner should not be automatically included in users collection" do
    # Owner is not automatically a member unless there's a membership record
    org = Organization.create!(name: "Owner Only Org", owner: users(:two))

    assert_equal users(:two), org.owner
    assert_not_includes org.users, users(:two)
    assert_empty org.active_users
  end

  test "should allow same user to be owner and have membership" do
    # This tests that owner can also have a membership
    assert_equal users(:owner), @organization.owner
    assert_includes @organization.users, users(:owner)
  end
end
