require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  def setup
    @membership = memberships(:owner_membership)
    @admin_membership = memberships(:admin_membership)
    @member_membership = memberships(:member_membership)
    @pending_membership = memberships(:pending_member)
    @inactive_membership = memberships(:inactive_member)
  end

  # Association tests
  test "should belong to user" do
    assert_respond_to @membership, :user
    assert_equal users(:owner), @membership.user
  end

  test "should belong to organization" do
    assert_respond_to @membership, :organization
    assert_equal organizations(:test_org), @membership.organization
  end

  # Attribute accessor tests
  test "should have email_address virtual attribute" do
    @membership.email_address = "test@example.com"
    assert_equal "test@example.com", @membership.email_address
  end

  # Enum tests
  test "should have role enum with correct values" do
    assert_respond_to @membership, :role
    assert_respond_to @membership, :member?
    assert_respond_to @membership, :admin?
    assert_respond_to @membership, :owner?
  end

  test "should have status enum with correct values" do
    assert_respond_to @membership, :status
    assert_respond_to @membership, :pending?
    assert_respond_to @membership, :active?
    assert_respond_to @membership, :inactive?
    assert_respond_to @membership, :suspended?
  end

  test "should correctly identify role types" do
    assert @membership.owner?
    assert_not @membership.admin?
    assert_not @membership.member?

    assert @admin_membership.admin?
    assert_not @admin_membership.owner?
    assert_not @admin_membership.member?

    assert @member_membership.member?
    assert_not @member_membership.admin?
    assert_not @member_membership.owner?
  end

  test "should correctly identify status types" do
    assert @membership.active?
    assert_not @membership.pending?
    assert_not @membership.inactive?
    assert_not @membership.suspended?

    assert @pending_membership.pending?
    assert_not @pending_membership.active?

    assert @inactive_membership.inactive?
    assert_not @inactive_membership.active?
  end

  # Validation tests
  test "should be valid with valid attributes" do
    membership = Membership.new(
      user: users(:two),
      organization: organizations(:public_org),
      role: :member,
      status: :pending
    )
    assert membership.valid?
  end

  test "should require user_id" do
    @membership.user = nil
    assert_not @membership.valid?
    assert_not_empty @membership.errors[:user]
  end

  test "should require organization_id" do
    @membership.organization = nil
    assert_not @membership.valid?
    assert_not_empty @membership.errors[:organization]
  end

  test "should require role presence" do
    @membership.role = nil
    assert_not @membership.valid?
    assert_not_empty @membership.errors[:role]
  end

  test "should require status presence" do
    @membership.status = nil
    assert_not @membership.valid?
    assert_not_empty @membership.errors[:status]
  end

  test "should enforce uniqueness of user_id scoped to organization_id" do
    duplicate_membership = Membership.new(
      user: @membership.user,
      organization: @membership.organization,
      role: :member,
      status: :pending
    )
    assert_not duplicate_membership.valid?
    assert_not_empty duplicate_membership.errors[:user_id]
  end

  test "should allow same user in different organizations" do
    different_org_membership = Membership.new(
      user: @membership.user,
      organization: organizations(:another_org),
      role: :member,
      status: :pending
    )
    assert different_org_membership.valid?
  end

  test "should allow different users in same organization" do
    different_user_membership = Membership.new(
      user: users(:two),
      organization: @membership.organization,
      role: :member,
      status: :pending
    )
    assert different_user_membership.valid?
  end

  test "should prevent user from being owner if already organization owner" do
    # Create a membership where user is trying to be owner of their own organization
    owner_user = users(:owner)
    owned_org = organizations(:test_org)

    membership = Membership.new(
      user: owner_user,
      organization: owned_org,
      role: :owner,
      status: :active
    )

    assert_not membership.valid?
    assert_not_empty membership.errors[:user]
  end

  test "should allow non-owner user to have owner role in membership" do
    # User can have owner role in membership if they're not the organization owner
    non_owner_user = users(:two)
    org = organizations(:test_org)

    membership = Membership.new(
      user: non_owner_user,
      organization: org,
      role: :owner,
      status: :active
    )

    assert membership.valid?
  end

  # Scope tests
  test "active_memberships scope should return only active memberships" do
    active_memberships = Membership.active_memberships
    assert_includes active_memberships, @membership
    assert_includes active_memberships, @admin_membership
    assert_includes active_memberships, @member_membership
    assert_not_includes active_memberships, @pending_membership
    assert_not_includes active_memberships, @inactive_membership
  end

  test "admin_memberships scope should return admin and owner roles" do
    admin_memberships = Membership.admin_memberships
    assert_includes admin_memberships, @membership # owner role
    assert_includes admin_memberships, @admin_membership # admin role
    assert_not_includes admin_memberships, @member_membership # member role
    assert_not_includes admin_memberships, @pending_membership # member role
  end

  # Public method tests
  test "can_manage_organization? should return true for admin and owner" do
    assert @membership.can_manage_organization?  # owner
    assert @admin_membership.can_manage_organization?  # admin
    assert_not @member_membership.can_manage_organization?  # member
  end

  test "can_manage_members? should return true for admin and owner" do
    assert @membership.can_manage_members?  # owner
    assert @admin_membership.can_manage_members?  # admin
    assert_not @member_membership.can_manage_members?  # member
  end

  test "can_manage_organization? should work regardless of status" do
    # Create an inactive admin membership
    inactive_admin = Membership.create!(
      user: users(:two),
      organization: organizations(:public_org),
      role: :admin,
      status: :inactive
    )

    assert inactive_admin.can_manage_organization?
  end

  test "can_manage_members? should work regardless of status" do
    # Create a suspended owner membership
    suspended_owner = Membership.create!(
      user: users(:two),
      organization: organizations(:public_org),
      role: :owner,
      status: :suspended
    )

    assert suspended_owner.can_manage_members?
  end

  # Edge case tests
  test "should handle role changes" do
    @member_membership.role = :admin
    assert @member_membership.admin?
    assert_not @member_membership.member?
    assert @member_membership.can_manage_organization?
  end

  test "should handle status changes" do
    @membership.status = :suspended
    assert @membership.suspended?
    assert_not @membership.active?
    # Should still be able to manage since role is owner
    assert @membership.can_manage_organization?
  end

  test "should allow all role and status combinations" do
    # Test all valid combinations
    roles = [ :member, :admin, :owner ]
    statuses = [ :pending, :active, :inactive, :suspended ]

    roles.each do |role|
      statuses.each do |status|
        membership = Membership.new(
          user: users(:two),
          organization: organizations(:public_org),
          role: role,
          status: status
        )

        # Skip the owner validation case
        unless role == :owner && membership.organization&.owner == membership.user
          assert membership.valid?, "Should be valid with role: #{role}, status: #{status}"
        end
      end
    end
  end

  test "should maintain referential integrity" do
    user = @membership.user
    organization = @membership.organization

    assert_equal user, @membership.user
    assert_equal organization, @membership.organization
    assert_includes user.memberships, @membership
    assert_includes organization.memberships, @membership
  end

  # Business logic tests
  test "should differentiate between organization owner and membership owner role" do
    # Organization owner (from belongs_to :owner in Organization)
    org_owner = organizations(:test_org).owner
    assert_equal users(:owner), org_owner

    # Membership with owner role
    membership_with_owner_role = memberships(:owner_membership)
    assert membership_with_owner_role.owner?

    # These could be different users in a real scenario
    # But in our fixtures, they happen to be the same user
    assert_equal org_owner, membership_with_owner_role.user
  end

  test "should handle enum edge cases" do
    # Test string assignment to enums
    @membership.role = "admin"
    assert @membership.admin?

    @membership.status = "pending"
    assert @membership.pending?

    # Test integer assignment to enums
    @membership.role = 0  # member
    assert @membership.member?

    @membership.status = 0  # pending
    assert @membership.pending?
  end
end
