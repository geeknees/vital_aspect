class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Organization associations
  has_many :owned_organizations, class_name: "Organization", foreign_key: "owner_id", dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  # Evaluation associations
  has_many :created_evaluations, class_name: "Evaluation", foreign_key: "evaluator_id", dependent: :destroy
  has_many :evaluation_participants, dependent: :destroy
  has_many :evaluations, through: :evaluation_participants

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

  def member_of?(organization)
    return false unless organization
    memberships.joins(:organization).where(organization: organization).exists?
  end

  def can_create_evaluation?(organization)
    return false unless organization

    organization.owner == self ||
    memberships.find_by(organization: organization)&.can_manage_organization?
  end

  def pending_evaluations
    evaluation_participants.includes(:evaluation)
                          .where(status: [ :invited, :in_progress ])
                          .where(evaluations: { status: :active })
  end

  def completed_evaluations
    evaluation_participants.includes(:evaluation)
                          .where(status: :completed)
  end
end
