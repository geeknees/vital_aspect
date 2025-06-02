class EvaluationResponsesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_evaluation
  before_action :set_evaluation_participant
  before_action :check_participant_access

  def participate
    @questions = @evaluation.questions.order(:order_index)
    @responses = current_responses_hash
  end

  def submit
    responses_params = params[:responses] || {}
    errors = []

    ActiveRecord::Base.transaction do
      @evaluation.questions.each do |question|
        response_data = responses_params[question.id.to_s]
        next if response_data.blank?

        response = find_or_initialize_response(question)

        case question.question_type
        when "rating", "multiple_choice"
          response.content = response_data[:content]
        when "text"
          response.content = response_data[:content]
        when "yes_no"
          response.content = response_data[:content]
        end

        unless response.save
          errors.concat(response.errors.full_messages)
        end
      end

      if errors.empty?
        @evaluation_participant.update!(status: "completed")
      else
        raise ActiveRecord::Rollback
      end
    end

    if errors.empty?
      redirect_to organization_evaluation_path(@organization, @evaluation),
                  notice: t("responses.submitted_successfully")
    else
      @questions = @evaluation.questions.order(:order_index)
      @responses = current_responses_hash
      flash.now[:alert] = t("responses.submission_failed")
      render :participate, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_evaluation
    @evaluation = @organization.evaluations.find(params[:evaluation_id])
  end

  def set_evaluation_participant
    @evaluation_participant = @evaluation.evaluation_participants
                                         .find_by(user: Current.user)
  end

  def check_participant_access
    unless @evaluation_participant
      redirect_to root_path, alert: t("evaluations.not_participant")
      return
    end

    unless @evaluation.active?
      redirect_to root_path, alert: t("evaluations.not_active")
      return
    end

    if @evaluation_participant.completed?
      redirect_to organization_evaluation_path(@organization, @evaluation),
                  notice: t("responses.already_completed")
    end
  end

  def current_responses_hash
    responses = {}
    @evaluation_participant.responses.includes(:question).each do |response|
      responses[response.question_id] = response
    end
    responses
  end

  def find_or_initialize_response(question)
    @evaluation_participant.responses.find_or_initialize_by(
      question: question
    ) do |response|
      response.evaluation_participant = @evaluation_participant
    end
  end
end
