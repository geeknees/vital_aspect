class MembershipsController < ApplicationController
  before_action :set_organization
  before_action :set_membership, only: [ :show, :update, :destroy ]
  before_action :authenticate_user!
  before_action :check_organization_access!

  def index
    @memberships = @organization.memberships.includes(:user)
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
      redirect_to [@organization, :memberships], alert: t("memberships.unauthorized")
      return
    end
    
    @user = User.find_by(email_address: membership_params[:email_address])

    unless @user
      redirect_to [ @organization, :memberships ], alert: t("memberships.user_not_found")
      return
    end

    @membership = @organization.memberships.build(
      user: @user,
      role: membership_params[:role],
      status: "pending"
    )

    if @membership.save
      redirect_to [ @organization, :memberships ], notice: t("memberships.invitation_sent")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # 権限チェック：メンバー管理権限がない場合は拒否
    unless can_manage_members?
      redirect_to [@organization, :memberships], alert: t("memberships.unauthorized")
      return
    end
    
    # 所有者以外が所有者の情報を変更しようとした場合は拒否
    if @membership.user == @organization.owner && @organization.owner != Current.user
      redirect_to [@organization, :memberships], alert: t("memberships.cannot_modify_owner")
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
    permitted_params = [:email_address]
    
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
        permitted_params = [:role, :status]
      else
        # 管理者の場合は制限付きで許可
        current_membership = @organization.memberships.find_by(user: Current.user)
        target_membership = @membership
        
        # 自分より上位の役割や同じ管理者の役割は変更不可
        if target_membership.user != @organization.owner && 
           !(target_membership.admin? && current_membership.admin?)
          permitted_params = [:role, :status]
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

    # Admin can't remove other admins unless they are owner
    !(membership.admin? && current_membership.admin?)
  end
end
