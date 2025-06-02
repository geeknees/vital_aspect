class EvaluationParticipantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_evaluation
  before_action :set_evaluation_participant, only: [ :show, :edit, :update, :destroy ]
  before_action :check_organization_member
  before_action :check_evaluation_manager

  def index
    @evaluation_participants = @evaluation.evaluation_participants.includes(:user)
                                         .group_by(&:role)
  end

  def show
  end

  def new
    @evaluation_participant = @evaluation.evaluation_participants.build
    # Get available users in the organization who are not already participants
    @available_users = @organization.users.where.not(
      id: @evaluation.evaluation_participants.select(:user_id)
    )
  end

  def create
    user_id = params[:evaluation_participant][:user_id]
    
    # Security: Only allow users who are members of the organization
    user = @organization.users.find_by(id: user_id)
    unless user
      redirect_to organization_evaluation_path(@organization, @evaluation),
                  alert: t("evaluation_participants.user_not_found")
      return
    end

    @evaluation_participant = @evaluation.evaluation_participants.build(evaluation_participant_params)
    @evaluation_participant.user = user

    if @evaluation_participant.save
      # Send invitation email
      EvaluationMailer.invitation(@evaluation_participant).deliver_later

      redirect_to organization_evaluation_path(@organization, @evaluation),
                  notice: t("evaluation_participants.created_successfully")
    else
      @available_users = @organization.users.where.not(
        id: @evaluation.evaluation_participants.select(:user_id)
      )
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @evaluation_participant.update(evaluation_participant_params)
      redirect_to organization_evaluation_path(@organization, @evaluation),
                  notice: t("evaluation_participants.updated_successfully")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @evaluation_participant.destroy
    redirect_to organization_evaluation_path(@organization, @evaluation),
                notice: t("evaluation_participants.deleted_successfully")
  end

  def bulk_create
    user_ids = params[:user_ids] || []
    role = params[:role]

    # Validate role is one of the allowed enum values
    unless role.present? && EvaluationParticipant.roles.key?(role)
      redirect_to organization_evaluation_path(@organization, @evaluation),
                  alert: t("evaluation_participants.invalid_role")
      return
    end

    if user_ids.empty?
      redirect_to organization_evaluation_path(@organization, @evaluation),
                  alert: t("evaluation_participants.no_users_selected")
      return
    end

    created_count = 0
    user_ids.each do |user_id|
      next if user_id.blank?

      # Security: Only allow users who are members of the organization
      user = @organization.users.find_by(id: user_id)
      next unless user

      participant = @evaluation.evaluation_participants.build(
        user: user,
        role: role,
        status: "invited"
      )

      if participant.save
        created_count += 1
        # Send invitation email
        EvaluationMailer.invitation(participant).deliver_later
      end
    end

    redirect_to organization_evaluation_path(@organization, @evaluation),
                notice: t("evaluation_participants.bulk_created_successfully", count: created_count)
  end

  private

  def set_organization
    @organization = Current.user.organizations.find(params[:organization_id])
  end

  def set_evaluation
    @evaluation = @organization.evaluations.find(params[:evaluation_id])
  end

  def set_evaluation_participant
    @evaluation_participant = @evaluation.evaluation_participants.find(params[:id])
  end

  def check_organization_member
    unless Current.user.member_of?(@organization)
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

  def evaluation_participant_params
    # Only allow valid role values for security reasons
    # user_id should be set explicitly in controller actions
    role_param = params.dig(:evaluation_participant, :role)
    
    # Only permit if role is a valid enum value
    if role_param.present? && EvaluationParticipant.roles.key?(role_param.to_s)
      { role: role_param }
    else
      {}
    end
  end
end
