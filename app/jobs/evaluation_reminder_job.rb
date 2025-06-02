class EvaluationReminderJob < ApplicationJob
  queue_as :default

  def perform(evaluation_participant_id = nil)
    if evaluation_participant_id
      # Send reminder for a specific participant
      participant = EvaluationParticipant.find(evaluation_participant_id)
      send_reminder_for_participant(participant) if participant.needs_reminder?
    else
      # Send reminders for all participants who need them
      send_all_reminders
    end
  end

  private

  def send_all_reminders
    # Find all participants who need reminders
    participants_needing_reminders = EvaluationParticipant
      .joins(:evaluation)
      .where(status: [ "invited", "in_progress" ])
      .where(evaluations: { status: "active" })
      .where("evaluations.due_date >= ? AND evaluations.due_date <= ?",
             Date.current, 3.days.from_now)

    participants_needing_reminders.find_each do |participant|
      send_reminder_for_participant(participant)
    end
  end

  def send_reminder_for_participant(participant)
    begin
      EvaluationMailer.reminder(participant).deliver_now
      Rails.logger.info "Reminder email sent to #{participant.user.email} for evaluation #{participant.evaluation.name}"
    rescue => e
      Rails.logger.error "Failed to send reminder email to #{participant.user.email}: #{e.message}"
      raise e
    end
  end
end
