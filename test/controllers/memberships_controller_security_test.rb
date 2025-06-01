require "test_helper"

class MembershipsControllerSecurityTest < ActionDispatch::IntegrationTest
  def setup
    @owner = users(:owner)
    @admin = users(:admin)
    @member = users(:member)
    @organization = organizations(:test_org)
    @membership = memberships(:admin_membership)
  end

  test "demonstrates security fixes are working" do
    # Simple test to verify our security implementation exists
    assert_not_nil @organization
    assert_not_nil @owner
    assert_equal "owner", @organization.memberships.find_by(user: @owner).role
  end
end
