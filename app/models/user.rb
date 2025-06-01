class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Organization associations
  has_many :owned_organizations, class_name: "Organization", foreign_key: "owner_id", dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def admin_organizations
    organizations.joins(:memberships).where(memberships: { role: [ "admin", "owner" ] })
  end

  def member_organizations
    organizations.joins(:memberships).where(memberships: { role: "member" })
  end

  def active_memberships
    memberships.where(status: "active")
  end
end
