class MembershipsController < ApplicationController
  before_action :set_organization
  before_action :set_membership, only: [ :show, :update, :destroy ]
  before_action :authenticate_user!
  before_action :check_organization_access!

  helper_method :can_remove_member?

  def index
    @memberships = @organization.memberships.includes(:user)
                                            .where(status: [ "active", "pending" ])
                                            .order(:status, :created_at)
    @can_manage = can_manage_members?
  end

  def show
  end

  def new
    @membership = @organization.memberships.build
  end

  def create
    # 権限チェック：メンバー管理権限がない場合は拒否
    unless can_manage_members?
      redirect_to [ @organization, :memberships ], alert: t("memberships.unauthorized")
      return
    end

    email_address = membership_params[:email_address]&.strip&.downcase

    # メールアドレスの基本チェック
    if email_address.blank?
      @membership = @organization.memberships.build
      @membership.email_address = membership_params[:email_address]
      @membership.errors.add(:email_address, t("memberships.errors.email_required"))
      render :new, status: :unprocessable_entity
      return
    end

    # メールアドレス形式チェック
    unless email_address.match?(URI::MailTo::EMAIL_REGEXP)
      @membership = @organization.memberships.build
      @membership.email_address = email_address
      @membership.errors.add(:email_address, t("memberships.errors.email_invalid"))
      render :new, status: :unprocessable_entity
      return
    end

    @user = User.find_by(email_address: email_address)

    # ユーザーが存在しない場合
    unless @user
      @membership = @organization.memberships.build
      @membership.email_address = email_address
      @membership.errors.add(:email_address, t("memberships.errors.user_not_found", email: email_address))
      render :new, status: :unprocessable_entity
      return
    end

    # 組織所有者を招待しようとした場合
    if @user == @organization.owner
      @membership = @organization.memberships.build
      @membership.email_address = email_address
      @membership.errors.add(:user, t("memberships.errors.cannot_invite_owner"))
      render :new, status: :unprocessable_entity
      return
    end

    # 既にメンバーの場合
    existing_membership = @organization.memberships.find_by(user: @user)
    if existing_membership
      @membership = @organization.memberships.build
      @membership.email_address = email_address

      case existing_membership.status
      when "active"
        @membership.errors.add(:user, t("memberships.errors.already_active_member"))
      when "pending"
        @membership.errors.add(:user, t("memberships.errors.already_invited"))
      when "suspended"
        @membership.errors.add(:user, t("memberships.errors.user_suspended"))
      when "inactive"
        # 非アクティブメンバーの場合は再招待可能
        existing_membership.update(status: "pending", role: membership_params[:role] || "member")
        redirect_to [ @organization, :memberships ],
                    notice: t("memberships.invitation_resent",
                             user_name: @user.name,
                             email: @user.email_address)
        return
      end

      render :new, status: :unprocessable_entity
      return
    end

    @membership = @organization.memberships.build(
      user: @user,
      role: membership_params[:role] || "member",
      status: "pending"
    )

    if @membership.save
      redirect_to [ @organization, :memberships ],
                  notice: t("memberships.invitation_sent",
                           user_name: @user.email_address.split("@").first,
                           email: @user.email_address)
    else
      @membership.email_address = email_address # フォーム再表示用
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # 権限チェック：メンバー管理権限がない場合は拒否
    unless can_manage_members?
      redirect_to [ @organization, :memberships ], alert: t("memberships.unauthorized")
      return
    end

    # 所有者以外が所有者の情報を変更しようとした場合は拒否
    if @membership.user == @organization.owner && @organization.owner != Current.user
      redirect_to [ @organization, :memberships ], alert: t("memberships.cannot_modify_owner")
      return
    end

    if @membership.update(membership_update_params)
      redirect_to [ @organization, @membership ], notice: t("memberships.updated_successfully")
    else
      redirect_to [ @organization, @membership ], alert: t("memberships.update_failed")
    end
  end

  def destroy
    unless can_remove_member?(@membership)
      redirect_to [ @organization, :memberships ], alert: t("memberships.unauthorized")
      return
    end

    @membership.destroy
    redirect_to [ @organization, :memberships ], notice: t("memberships.removed_successfully")
  end

  def accept
    @membership = @organization.memberships.find_by(user: Current.user, status: "pending")

    if @membership&.update(status: "active")
      redirect_to @organization, notice: t("memberships.invitation_accepted")
    else
      redirect_to organizations_path, alert: t("memberships.invitation_not_found")
    end
  end

  def decline
    @membership = @organization.memberships.find_by(user: Current.user, status: "pending")

    if @membership
      @membership.destroy
      redirect_to organizations_path, notice: t("memberships.invitation_declined")
    else
      redirect_to organizations_path, alert: t("memberships.invitation_not_found")
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_membership
    @membership = @organization.memberships.find(params[:id])
  end

  def membership_params
    # 招待時は email_address のみ許可し、role は管理者権限がある場合のみ許可
    permitted_params = [ :email_address ]

    if can_manage_members?
      permitted_params << :role
    end

    params.require(:membership).permit(permitted_params)
  end

  def membership_update_params
    # 更新時は管理者権限がある場合のみ role と status を許可
    return params.require(:membership).permit() unless can_manage_members?

    # 所有者でない場合の追加制限
    permitted_params = []

    if can_manage_members?
      # 所有者の場合はすべて許可
      if @organization.owner == Current.user
        permitted_params = [ :role, :status ]
      else
        # 管理者の場合は制限付きで許可
        current_membership = @organization.memberships.find_by(user: Current.user)
        target_membership = @membership

        # 自分より上位の役割や同じ管理者の役割は変更不可
        if target_membership.user != @organization.owner &&
           !(target_membership.admin? && current_membership.admin?)
          permitted_params = [ :role, :status ]
        end
      end
    end

    params.require(:membership).permit(permitted_params)
  end

  def authenticate_user!
    redirect_to new_session_path unless Current.user
  end

  def check_organization_access!
    unless @organization.users.include?(Current.user) || @organization.owner == Current.user
      redirect_to organizations_path, alert: t("organizations.unauthorized")
    end
  end

  def can_manage_members?
    @organization.owner == Current.user ||
    @organization.memberships.find_by(user: Current.user)&.can_manage_members?
  end

  def can_remove_member?(membership)
    return false if membership.user == @organization.owner
    return true if @organization.owner == Current.user

    current_membership = @organization.memberships.find_by(user: Current.user)
    return false unless current_membership&.can_manage_members?

    # 招待中（pending）のメンバーは管理者でも削除可能
    return true if membership.pending?

    # Admin can't remove other admins unless they are owner
    !(membership.admin? && current_membership.admin?)
  end
end
