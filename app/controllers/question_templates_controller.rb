class QuestionTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_question_template, only: [ :edit, :update, :destroy ]
  before_action :check_organization_member
  before_action :check_manage_permission

  def index
    @question_templates = @organization.question_templates.order(created_at: :desc)
  end

  def new
    @question_template = @organization.question_templates.build
    @question_template.options = [ "" ] if @question_template.options.nil?
  end

  def create
    @question_template = @organization.question_templates.build(question_template_params)

    if @question_template.save
      redirect_to organization_question_templates_path(@organization), notice: t("question_templates.created_successfully")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @question_template.update(question_template_params)
      redirect_to organization_question_templates_path(@organization), notice: t("question_templates.updated_successfully")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @question_template.destroy
    redirect_to organization_question_templates_path(@organization), notice: t("question_templates.deleted_successfully")
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_question_template
    @question_template = @organization.question_templates.find(params[:id])
  end

  def check_organization_member
    unless Current.session.user.member_of?(@organization)
      redirect_to root_path, alert: t("organizations.access_denied")
    end
  end

  def check_manage_permission
    unless Current.session.user.can_create_evaluation?(@organization)
      redirect_to organization_path(@organization), alert: t("evaluations.access_denied")
    end
  end

  def question_template_params
    permitted_params = params.require(:question_template).permit(:text, :question_type, :is_required, options: [])
    if permitted_params[:text]
      permitted_params[:content] = permitted_params.delete(:text)
    end
    if permitted_params[:options]
      permitted_params[:options] = permitted_params[:options].reject(&:blank?)
    end
    permitted_params
  end
end
