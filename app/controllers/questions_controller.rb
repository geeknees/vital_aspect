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
    @organization = Current.session.user.organizations.find(params[:organization_id])
  end

  def set_evaluation
    @evaluation = @organization.evaluations.find(params[:evaluation_id])
  end

  def set_question
    @question = @evaluation.questions.find(params[:id])
  end

  def check_organization_member
    unless Current.session.user.member_of?(@organization)
      redirect_to root_path, alert: t("organizations.access_denied")
    end
  end

  def check_evaluation_manager
    unless can_manage_evaluation?(@evaluation)
      redirect_to organization_evaluation_path(@organization, @evaluation),
                  alert: t("evaluations.access_denied")
    end
  end

  def question_params
    params.require(:question).permit(:text, :question_type, :required, options: [])
  end
end
