class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :role, [
    :member,  # Regular member with basic permissions
    :admin,   # Admin with elevated permissions
    :owner    # Owner with full permissions
  ]

  enum :status, [
    :pending,  # Membership request is pending approval
    :active,   # Membership is active
    :inactive, # Membership is inactive (e.g., user left organization)
    :suspended # Membership is suspended (e.g., due to violation of rules)
  ]

  validates :user_id, uniqueness: { scope: :organization_id }
  validates :role, presence: true
  validates :status, presence: true

  scope :active_memberships, -> { where(status: :active) }
  scope :admin_memberships, -> { where(role: [ :admin, :owner ]) }

  def can_manage_organization?
    admin? || owner?
  end

  def can_manage_members?
    admin? || owner?
  end
end
