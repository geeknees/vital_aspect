class OkrsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_okr, only: [ :show, :edit, :update, :destroy, :activate ]
  before_action :check_organization_member
  before_action :check_okr_owner, only: [ :edit, :update, :destroy, :activate ]

  def index
    @okrs = @organization.okrs.includes(:user, :key_results)
                              .order(:start_date, :end_date)

    # フィルタリング
    case params[:filter]
    when "my_okrs"
      @okrs = @okrs.where(user: Current.user)
    when "current"
      @okrs = @okrs.current
    when "upcoming"
      @okrs = @okrs.upcoming
    when "completed"
      @okrs = @okrs.completed
    end

    @okrs = @okrs.page(params[:page])
  end

  def show
    @key_results = @okr.key_results.order(:created_at)
    @progress_history = @okr.okr_progresses.recent.limit(10)
    @can_edit = can_edit_okr?(@okr)
  end

  def new
    @okr = @organization.okrs.build(user: Current.user)
    @okr.key_results.build # 初期のKey Result
  end

  def create
    @okr = @organization.okrs.build(okr_params)
    @okr.user = Current.user

    if @okr.save
      redirect_to organization_okr_path(@organization, @okr),
                  notice: t("okrs.created_successfully")
    else
      @okr.key_results.build if @okr.key_results.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @okr.key_results.build if @okr.key_results.empty?
  end

  def update
    if @okr.update(okr_params)
      redirect_to organization_okr_path(@organization, @okr),
                  notice: t("okrs.updated_successfully")
    else
      @okr.key_results.build if @okr.key_results.empty?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @okr.destroy
    redirect_to organization_okrs_path(@organization),
                notice: t("okrs.deleted_successfully")
  end

  def activate
    if @okr.draft?
      @okr.update(status: :active)
      redirect_to organization_okr_path(@organization, @okr),
                notice: t("okrs.activated_successfully")
    else
      redirect_to organization_okr_path(@organization, @okr),
                alert: t("okrs.already_activated")
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
    unless Current.user.member_of?(@organization)
      redirect_to organizations_path, alert: t("organizations.access_denied")
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to organizations_path, alert: t("organizations.not_found")
  end

  def set_okr
    @okr = @organization.okrs.find(params[:id])
  end

  def check_organization_member
    unless Current.user.member_of?(@organization)
      redirect_to root_path, alert: t("organizations.access_denied")
    end
  end

  def check_okr_owner
    unless can_edit_okr?(@okr)
      redirect_to organization_okr_path(@organization, @okr),
                  alert: t("okrs.access_denied")
    end
  end

  def can_edit_okr?(okr)
    okr.user == Current.user ||
    @organization.owner == Current.user ||
    @organization.memberships.find_by(user: Current.user)&.can_manage_organization?
  end

  def okr_params
    params.require(:okr).permit(
      :title, :description, :status, :start_date, :end_date,
      key_results_attributes: [
        :id, :title, :description, :target_value, :current_value, :unit, :status, :_destroy
      ]
    )
  end
end
