class EvaluationsController < ApplicationController
  before_action :set_organization
  before_action :set_evaluation, only: [ :show, :edit, :update, :destroy, :start, :complete ]
  before_action :authenticate_user!
  before_action :check_organization_access!
  before_action :check_evaluation_management_permission!, except: [ :index, :show ]

  def index
    @evaluations = @organization.evaluations.includes(:evaluator, :evaluation_participants)
                                .order(created_at: :desc)
    @can_create = Current.user.can_create_evaluation?(@organization)
  end

  def show
    @participant = @evaluation.evaluation_participants.find_by(user: Current.user)
    @questions = @evaluation.questions.ordered
    @can_edit = can_edit_evaluation?
    @can_start = @evaluation.can_start?
    @can_complete = @evaluation.can_complete?
    @participants_summary = participants_summary
  end

  def new
    @evaluation = @organization.evaluations.build
    @evaluation.evaluator = Current.user
    @evaluation.start_date = Date.current
    @evaluation.due_date = 2.weeks.from_now
  end

  def create
    @evaluation = @organization.evaluations.build(evaluation_params)
    @evaluation.evaluator = Current.user

    if @evaluation.save
      redirect_to [ @organization, @evaluation ], notice: "360度評価が作成されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless @evaluation.can_edit?
      redirect_to [ @organization, @evaluation ], alert: "実施中または完了した評価は編集できません。"
    end
  end

  def update
    unless @evaluation.can_edit?
      redirect_to [ @organization, @evaluation ], alert: "実施中または完了した評価は編集できません。"
      return
    end

    if @evaluation.update(evaluation_params)
      redirect_to [ @organization, @evaluation ], notice: "360度評価が更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless @evaluation.can_edit?
      redirect_to [ @organization, @evaluation ], alert: "実施中または完了した評価は削除できません。"
      return
    end

    @evaluation.destroy
    redirect_to [ @organization, :evaluations ], notice: "360度評価が削除されました。"
  end

  def start
    unless @evaluation.can_start?
      redirect_to [ @organization, @evaluation ], alert: "評価を開始できません。質問と参加者を設定してください。"
      return
    end

    if @evaluation.update(status: :active)
      # 参加者のステータスを invited に設定
      @evaluation.evaluation_participants.update_all(status: :invited)
      redirect_to [ @organization, @evaluation ], notice: "360度評価を開始しました。"
    else
      redirect_to [ @organization, @evaluation ], alert: "評価の開始に失敗しました。"
    end
  end

  def complete
    unless @evaluation.can_complete?
      redirect_to [ @organization, @evaluation ], alert: "評価を完了できません。"
      return
    end

    if @evaluation.update(status: :completed)
      redirect_to [ @organization, @evaluation ], notice: "360度評価が完了しました。"
    else
      redirect_to [ @organization, @evaluation ], alert: "評価の完了に失敗しました。"
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_evaluation
    @evaluation = @organization.evaluations.find(params[:id])
  end

  def evaluation_params
    params.require(:evaluation).permit(:title, :description, :start_date, :due_date)
  end

  def authenticate_user!
    redirect_to new_session_path unless Current.user
  end

  def check_organization_access!
    unless @organization.users.include?(Current.user) || @organization.owner == Current.user
      redirect_to organizations_path, alert: "この組織にアクセスする権限がありません。"
    end
  end

  def check_evaluation_management_permission!
    unless Current.user.can_create_evaluation?(@organization)
      redirect_to [ @organization, :evaluations ], alert: "360度評価を管理する権限がありません。"
    end
  end

  def can_edit_evaluation?
    @evaluation.can_edit? && Current.user.can_create_evaluation?(@organization)
  end

  def participants_summary
    {
      total: @evaluation.evaluation_participants.count,
      completed: @evaluation.evaluation_participants.completed_participants.count,
      in_progress: @evaluation.evaluation_participants.where(status: :in_progress).count,
      invited: @evaluation.evaluation_participants.where(status: :invited).count
    }
  end
end
