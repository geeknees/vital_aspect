class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  # フォームでのエラー表示用の仮想属性
  attr_accessor :email_address

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

  validates :user_id, uniqueness: {
    scope: :organization_id,
    message: :already_member
  }
  validates :role, presence: true
  validates :status, presence: true
  validate :user_cannot_be_owner, if: -> { organization&.owner == user }

  private

  def user_cannot_be_owner
    errors.add(:user, :cannot_invite_owner)
  end

  scope :active_memberships, -> { where(status: :active) }
  scope :admin_memberships, -> { where(role: [ :admin, :owner ]) }

  def can_manage_organization?
    admin? || owner?
  end

  def can_manage_members?
    admin? || owner?
  end
end
