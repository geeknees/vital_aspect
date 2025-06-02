class Organization < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

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
end
