class EvaluationMailer < ApplicationMailer
  def invitation(evaluation_participant)
    @evaluation_participant = evaluation_participant
    @evaluation = evaluation_participant.evaluation
    @organization = @evaluation.organization
    @user = evaluation_participant.user
    @participation_url = participate_organization_evaluation_evaluation_responses_url(
      @organization,
      @evaluation,
      host: default_url_options[:host]
    )

    mail(
      to: @user.email_address,
      subject: t("evaluation_mailer.invitation.subject",
                 evaluation_title: @evaluation.title,
                 organization_name: @organization.name)
    )
  end

  def reminder(evaluation_participant)
    @evaluation_participant = evaluation_participant
    @evaluation = evaluation_participant.evaluation
    @organization = @evaluation.organization
    @user = evaluation_participant.user
    @participation_url = participate_organization_evaluation_evaluation_responses_url(
      @organization,
      @evaluation,
      host: default_url_options[:host]
    )

    mail(
      to: @user.email_address,
      subject: t("evaluation_mailer.reminder.subject",
                 evaluation_title: @evaluation.title,
                 organization_name: @organization.name)
    )
  end

  def completion_notification(evaluation)
    @evaluation = evaluation
    @organization = evaluation.organization
    @evaluator = evaluation.created_by
    @completion_stats = {
      total_participants: evaluation.evaluation_participants.count,
      completed_participants: evaluation.evaluation_participants.completed.count,
      completion_rate: evaluation.progress_percentage
    }

    mail(
      to: @evaluator.email_address,
      subject: t("evaluation_mailer.completion_notification.subject",
                 evaluation_title: @evaluation.title)
    )
  end
end
