class OkrProgressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_okr
  before_action :set_okr_progress, only: [:show, :edit, :update, :destroy]
  before_action :check_organization_member
  before_action :check_okr_owner

  def index
    @progress_history = @okr.okr_progresses.recent
                            .includes(:okr)
                            .page(params[:page])
  end

  def show
  end

  def new
    @okr_progress = @okr.okr_progresses.build(
      reported_at: Date.current,
      completion_percentage: @okr.progress_percentage
    )
  end

  def create
    @okr_progress = @okr.okr_progresses.build(okr_progress_params)

    if @okr_progress.save
      redirect_to organization_okr_path(@organization, @okr),
                  notice: t('okr_progresses.created_successfully')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @okr_progress.update(okr_progress_params)
      redirect_to organization_okr_path(@organization, @okr),
                  notice: t('okr_progresses.updated_successfully')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @okr_progress.destroy
    redirect_to organization_okr_path(@organization, @okr),
                notice: t('okr_progresses.deleted_successfully')
  end

  private

  def set_organization
    @organization = Current.user.organizations.find(params[:organization_id])
  end

  def set_okr
    @okr = @organization.okrs.find(params[:okr_id])
  end

  def set_okr_progress
    @okr_progress = @okr.okr_progresses.find(params[:id])
  end

  def check_organization_member
    unless Current.user.member_of?(@organization)
      redirect_to root_path, alert: t('organizations.access_denied')
    end
  end

  def check_okr_owner
    unless can_edit_okr?(@okr)
      redirect_to organization_okr_path(@organization, @okr),
                  alert: t('okrs.access_denied')
    end
  end

  def can_edit_okr?(okr)
    okr.user == Current.user ||
    @organization.owner == Current.user ||
    @organization.memberships.find_by(user: Current.user)&.can_manage_organization?
  end

  def okr_progress_params
    params.require(:okr_progress).permit(:progress_note, :completion_percentage, :reported_at)
  end
end
