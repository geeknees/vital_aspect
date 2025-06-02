namespace :evaluation do
  desc "Send reminder emails to participants with pending evaluations"
  task send_reminders: :environment do
    puts "Sending evaluation reminder emails..."

    begin
      EvaluationReminderJob.perform_now
      puts "Reminder emails have been queued successfully."
    rescue => e
      puts "Error sending reminder emails: #{e.message}"
      Rails.logger.error "Evaluation reminder task failed: #{e.message}"
    end
  end

  desc "Send completion notifications for completed evaluations"
  task send_completion_notifications: :environment do
    puts "Sending completion notifications for recently completed evaluations..."

    # Find evaluations that were completed in the last 24 hours
    # and haven't had completion notifications sent yet
    recently_completed = Evaluation.where(
      status: "completed",
      updated_at: 24.hours.ago..Time.current
    )

    count = 0
    recently_completed.find_each do |evaluation|
      begin
        EvaluationMailer.completion_notification(evaluation).deliver_now
        count += 1
        puts "Completion notification sent for evaluation: #{evaluation.name}"
      rescue => e
        puts "Error sending completion notification for #{evaluation.name}: #{e.message}"
        Rails.logger.error "Failed to send completion notification for evaluation #{evaluation.id}: #{e.message}"
      end
    end

    puts "#{count} completion notifications sent."
  end

  desc "Show evaluation statistics and pending reminders"
  task stats: :environment do
    puts "\n=== Evaluation Statistics ==="

    total_evaluations = Evaluation.count
    active_evaluations = Evaluation.where(status: "active").count
    completed_evaluations = Evaluation.where(status: "completed").count

    puts "Total evaluations: #{total_evaluations}"
    puts "Active evaluations: #{active_evaluations}"
    puts "Completed evaluations: #{completed_evaluations}"

    puts "\n=== Participants Needing Reminders ==="

    participants_needing_reminders = EvaluationParticipant
      .joins(:evaluation)
      .where(status: [ "invited", "in_progress" ])
      .where(evaluations: { status: "active" })
      .where("evaluations.due_date >= ? AND evaluations.due_date <= ?",
             Date.current, 3.days.from_now)

    if participants_needing_reminders.any?
      participants_needing_reminders.includes(:user, :evaluation).each do |participant|
        puts "- #{participant.user.full_name} (#{participant.user.email}) - #{participant.evaluation.name} - Due: #{participant.evaluation.due_date}"
      end
    else
      puts "No participants need reminders at this time."
    end

    puts "\n=== Recent Activity ==="

    recent_completions = EvaluationParticipant
      .where(status: "completed", updated_at: 7.days.ago..Time.current)
      .count

    puts "Participants completed in last 7 days: #{recent_completions}"
  end
end
