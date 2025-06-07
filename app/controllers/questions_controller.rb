class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_evaluation
  before_action :set_question, only: [ :show, :edit, :update, :destroy ]
  before_action :check_organization_member
  before_action :check_evaluation_manager

  def index
    @questions = @evaluation.questions.order(:order_index)
  end

  def show
  end

  def new
    @question = @evaluation.questions.build
    @question.order_index = (@evaluation.questions.maximum(:order_index) || 0) + 1
    # Initialize options for multiple choice questions
    @question.options = [ "" ] if @question.options.nil?
  end

  def create
    @question = @evaluation.questions.build(question_params)
    @question.order_index = (@evaluation.questions.maximum(:order_index) || 0) + 1

    if @question.save
      redirect_to organization_evaluation_path(@organization, @evaluation),
                  notice: t("questions.created_successfully")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @question.update(question_params)
      redirect_to organization_evaluation_path(@organization, @evaluation),
                  notice: t("questions.updated_successfully")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    redirect_to organization_evaluation_path(@organization, @evaluation),
                notice: t("questions.deleted_successfully")
  end

  def reorder
    params[:question_ids].each_with_index do |id, index|
      @evaluation.questions.find(id).update!(order_index: index + 1)
    end

    head :ok
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_evaluation
    @evaluation = @organization.evaluations.find(params[:evaluation_id])
  end

  def set_question
    @question = @evaluation.questions.find(params[:id])
  end

  def check_organization_member
    unless @organization.users.include?(Current.session.user) || @organization.owner == Current.session.user
      redirect_to root_path, alert: t("organizations.access_denied")
    end
  end

  def check_evaluation_manager
    unless can_manage_evaluation?(@evaluation)
      redirect_to organization_evaluation_path(@organization, @evaluation),
                  alert: t("evaluations.access_denied")
    end
  end

  def can_manage_evaluation?(evaluation)
    Current.session.user == evaluation.created_by ||
    Current.session.user.can_create_evaluation?(evaluation.organization)
  end

  def question_params
    permitted_params = params.require(:question).permit(:text, :question_type, :is_required, options: [])
    # Map :text to :content since the model uses content
    if permitted_params[:text]
      permitted_params[:content] = permitted_params.delete(:text)
    end
    # Filter out empty options
    if permitted_params[:options]
      permitted_params[:options] = permitted_params[:options].reject(&:blank?)
    end
    permitted_params
  end
end
