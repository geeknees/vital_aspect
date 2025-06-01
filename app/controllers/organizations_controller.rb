class OrganizationsController < ApplicationController
  before_action :set_organization, only: [ :show, :edit, :update, :destroy ]
  before_action :authenticate_user!

  def index
    @owned_organizations = Current.user.owned_organizations.includes(:memberships, :users)
    @member_organizations = Current.user.organizations.includes(:memberships, :users)
  end

  def show
    @membership = @organization.memberships.find_by(user: Current.user)
    @members = @organization.memberships.includes(:user).active_memberships
    @can_manage = @membership&.can_manage_organization? || @organization.owner == Current.user
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Current.user.owned_organizations.build(organization_params)

    if @organization.save
      # Create owner membership
      @organization.memberships.create!(
        user: Current.user,
        role: "owner",
        status: "active"
      )
      redirect_to @organization, notice: t("organizations.created_successfully")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless can_edit_organization?
      redirect_to @organization, alert: t("organizations.unauthorized")
    end
  end

  def update
    unless can_edit_organization?
      redirect_to @organization, alert: t("organizations.unauthorized")
      return
    end

    if @organization.update(organization_params)
      redirect_to @organization, notice: t("organizations.updated_successfully")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless @organization.owner == Current.user
      redirect_to @organization, alert: t("organizations.unauthorized")
      return
    end

    @organization.destroy
    redirect_to organizations_path, notice: t("organizations.deleted_successfully")
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:name, :description)
  end

  def can_edit_organization?
    @organization.owner == Current.user ||
    @organization.memberships.find_by(user: Current.user)&.can_manage_organization?
  end

  def authenticate_user!
    redirect_to new_session_path unless Current.user
  end
end
