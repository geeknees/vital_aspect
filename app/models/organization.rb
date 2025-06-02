class Organization < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  # Evaluation associations
  has_many :evaluations, dependent: :destroy

  # OKR associations
  has_many :okrs, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }

  def admin_users
    users.joins(:memberships).where(memberships: { role: "admin" })
  end

  def member_users
    users.joins(:memberships).where(memberships: { role: "member" })
  end

  def active_users
    users.joins(:memberships).where(memberships: { status: "active" })
  end

  def pending_users
    users.joins(:memberships).where(memberships: { status: "pending" })
  end

  def all_users_including_pending
    users.joins(:memberships).where(memberships: { status: [ "active", "pending" ] })
  end

  def current_evaluations
    evaluations.current
  end

  def completed_evaluations
    evaluations.completed
  end
end
